import fs from 'node:fs'
import path from 'node:path'

function readBlocks(buffer) {
  const blocks = []
  let offset = 0
  while (offset + 8 <= buffer.length && blocks.length < 5000) {
    const name = buffer.toString('ascii', offset, offset + 4)
    const packed = buffer.readUInt32LE(offset + 4)
    const type = packed & 0x7f
    const units = (packed >>> 7) & 0x7ffff
    const size = units * 16
    blocks.push({ index: blocks.length, offset, name, type, size })
    if (!units) break
    offset += size
  }
  return blocks
}

function parseTexture(buffer, block) {
  if (block.type !== 0x20) return null
  const start = block.offset + 16
  const flag = buffer[start]
  if (![0xa1, 0x81, 0xb1].includes(flag)) return null
  const id = buffer.toString('ascii', start + 1, start + 17).replace(/\0/g, '').trim()
  const width = buffer.readInt32LE(start + 21)
  const height = buffer.readInt32LE(start + 25)
  if (width < 1 || height < 1 || width > 4096 || height > 4096) return null

  if (flag === 0xb1) {
    const paletteOffset = start + 64
    const pixelOffset = paletteOffset + 1024
    if (pixelOffset + width * height > block.offset + block.size) return null
    const rgba = Buffer.alloc(width * height * 4)
    for (let i = 0; i < width * height; i++) {
      const p = paletteOffset + buffer[pixelOffset + i] * 4
      const d = i * 4
      rgba[d] = buffer[p + 2]
      rgba[d + 1] = buffer[p + 1]
      rgba[d + 2] = buffer[p]
      rgba[d + 3] = buffer[p + 3] ? 255 : 0
    }
    return { ...block, id, flag, width, height, format: 'B1', rgba, pixelOffset, pixelSize: width * height }
  }

  const format = buffer.toString('ascii', start + 57, start + 61)
  const pixelSize = buffer.readUInt32LE(start + 61)
  const pixelOffset = start + 69
  if (!['1TXD', '3TXD'].includes(format) || pixelOffset + pixelSize > block.offset + block.size) return null
  const data = buffer.subarray(pixelOffset, pixelOffset + pixelSize)
  const rgba = format === '1TXD'
    ? decodeDxt1(data, width, height)
    : decodeDxt3(data, width, height)
  return { ...block, id, flag, width, height, format, rgba, pixelOffset, pixelSize }
}

function rgb565(value) {
  const r5 = (value >>> 11) & 31
  const g6 = (value >>> 5) & 63
  const b5 = value & 31
  return [
    (r5 << 3) | (r5 >>> 2),
    (g6 << 2) | (g6 >>> 4),
    (b5 << 3) | (b5 >>> 2),
  ]
}

function colorPalette(c0, c1) {
  const a = rgb565(c0)
  const b = rgb565(c1)
  if (c0 > c1) {
    return [a, b,
      a.map((v, i) => Math.floor((2 * v + b[i]) / 3)),
      a.map((v, i) => Math.floor((v + 2 * b[i]) / 3)),
    ]
  }
  return [a, b, a.map((v, i) => Math.floor((v + b[i]) / 2)), [0, 0, 0]]
}

function decodeDxt1(data, width, height) {
  const rgba = Buffer.alloc(width * height * 4)
  let src = 0
  for (let by = 0; by < Math.ceil(height / 4); by++) {
    for (let bx = 0; bx < Math.ceil(width / 4); bx++) {
      const c0 = data.readUInt16LE(src)
      const c1 = data.readUInt16LE(src + 2)
      const indices = data.readUInt32LE(src + 4)
      const palette = colorPalette(c0, c1)
      src += 8
      for (let py = 0; py < 4; py++) for (let px = 0; px < 4; px++) {
        const x = bx * 4 + px, y = by * 4 + py
        if (x >= width || y >= height) continue
        const index = (indices >>> (2 * (py * 4 + px))) & 3
        const d = (y * width + x) * 4
        rgba[d] = palette[index][0]
        rgba[d + 1] = palette[index][1]
        rgba[d + 2] = palette[index][2]
        rgba[d + 3] = c0 <= c1 && index === 3 ? 0 : 255
      }
    }
  }
  return rgba
}

function decodeDxt3(data, width, height) {
  const rgba = Buffer.alloc(width * height * 4)
  let src = 0
  for (let by = 0; by < Math.ceil(height / 4); by++) {
    for (let bx = 0; bx < Math.ceil(width / 4); bx++) {
      const alpha = data.subarray(src, src + 8)
      const c0 = data.readUInt16LE(src + 8)
      const c1 = data.readUInt16LE(src + 10)
      const indices = data.readUInt32LE(src + 12)
      const palette = colorPalette(c0, c1)
      src += 16
      for (let py = 0; py < 4; py++) for (let px = 0; px < 4; px++) {
        const x = bx * 4 + px, y = by * 4 + py
        if (x >= width || y >= height) continue
        const pi = py * 4 + px
        const index = (indices >>> (2 * pi)) & 3
        const a4 = pi % 2 ? alpha[pi >>> 1] >>> 4 : alpha[pi >>> 1] & 15
        const d = (y * width + x) * 4
        rgba[d] = palette[index][0]
        rgba[d + 1] = palette[index][1]
        rgba[d + 2] = palette[index][2]
        rgba[d + 3] = a4 * 17
      }
    }
  }
  return rgba
}

function writeBmp(filePath, width, height, rgba) {
  const stride = width * 4
  const out = Buffer.alloc(54 + stride * height)
  out.write('BM', 0, 'ascii')
  out.writeUInt32LE(out.length, 2)
  out.writeUInt32LE(54, 10)
  out.writeUInt32LE(40, 14)
  out.writeInt32LE(width, 18)
  out.writeInt32LE(height, 22)
  out.writeUInt16LE(1, 26)
  out.writeUInt16LE(32, 28)
  out.writeUInt32LE(stride * height, 34)
  for (let y = 0; y < height; y++) {
    const srcY = height - 1 - y
    for (let x = 0; x < width; x++) {
      const s = (srcY * width + x) * 4
      const d = 54 + y * stride + x * 4
      out[d] = rgba[s + 2]
      out[d + 1] = rgba[s + 1]
      out[d + 2] = rgba[s]
      out[d + 3] = rgba[s + 3]
    }
  }
  fs.writeFileSync(filePath, out)
}

function readBmp(filePath) {
  const data = fs.readFileSync(filePath)
  if (data.toString('ascii', 0, 2) !== 'BM') throw new Error('Replacement must be a BMP file')
  const pixelOffset = data.readUInt32LE(10)
  const width = data.readInt32LE(18)
  const rawHeight = data.readInt32LE(22)
  const height = Math.abs(rawHeight)
  const bpp = data.readUInt16LE(28)
  const compression = data.readUInt32LE(30)
  if (![24, 32].includes(bpp) || compression !== 0) throw new Error('Replacement BMP must be uncompressed 24-bit or 32-bit')
  const stride = Math.ceil(width * bpp / 32) * 4
  const rgba = Buffer.alloc(width * height * 4)
  for (let y = 0; y < height; y++) {
    const srcY = rawHeight > 0 ? height - 1 - y : y
    for (let x = 0; x < width; x++) {
      const s = pixelOffset + srcY * stride + x * (bpp / 8)
      const d = (y * width + x) * 4
      rgba[d] = data[s + 2]
      rgba[d + 1] = data[s + 1]
      rgba[d + 2] = data[s]
      rgba[d + 3] = bpp === 32 ? data[s + 3] : 255
    }
  }
  return { width, height, rgba }
}

function to565(r, g, b) {
  return ((r * 31 / 255 + 0.5) << 11) | ((g * 63 / 255 + 0.5) << 5) | (b * 31 / 255 + 0.5)
}

function selectEndpoints(pixels) {
  let mean = [0, 0, 0]
  for (const p of pixels) for (let c = 0; c < 3; c++) mean[c] += p[c]
  mean = mean.map(v => v / pixels.length)
  let axis = [1, 1, 1]
  for (let iteration = 0; iteration < 8; iteration++) {
    const next = [0, 0, 0]
    for (const p of pixels) {
      const d = [p[0] - mean[0], p[1] - mean[1], p[2] - mean[2]]
      const projection = d[0] * axis[0] + d[1] * axis[1] + d[2] * axis[2]
      for (let c = 0; c < 3; c++) next[c] += d[c] * projection
    }
    const length = Math.hypot(...next) || 1
    axis = next.map(v => v / length)
  }
  let min = Infinity, max = -Infinity, low = pixels[0], high = pixels[0]
  for (const p of pixels) {
    const projection = p[0] * axis[0] + p[1] * axis[1] + p[2] * axis[2]
    if (projection < min) { min = projection; low = p }
    if (projection > max) { max = projection; high = p }
  }
  let c0 = to565(high[0], high[1], high[2])
  let c1 = to565(low[0], low[1], low[2])
  if (c0 === c1) c0 = c0 < 0xffff ? c0 + 1 : c0
  if (c0 < c1) [c0, c1] = [c1, c0]
  return [c0, c1]
}

function encodeColorBlock(pixels) {
  const [c0, c1] = selectEndpoints(pixels)
  const palette = colorPalette(c0, c1)
  let indices = 0
  for (let i = 0; i < 16; i++) {
    let best = 0, bestDistance = Infinity
    for (let p = 0; p < 4; p++) {
      const dr = pixels[i][0] - palette[p][0]
      const dg = pixels[i][1] - palette[p][1]
      const db = pixels[i][2] - palette[p][2]
      const distance = dr * dr * 3 + dg * dg * 4 + db * db * 2
      if (distance < bestDistance) { bestDistance = distance; best = p }
    }
    indices = (indices | (best << (2 * i))) >>> 0
  }
  const out = Buffer.alloc(8)
  out.writeUInt16LE(c0, 0)
  out.writeUInt16LE(c1, 2)
  out.writeUInt32LE(indices, 4)
  return out
}

function encodeDxt(rgba, width, height, format) {
  const blockSize = format === '3TXD' ? 16 : 8
  const out = Buffer.alloc(Math.ceil(width / 4) * Math.ceil(height / 4) * blockSize)
  let dst = 0
  for (let by = 0; by < Math.ceil(height / 4); by++) for (let bx = 0; bx < Math.ceil(width / 4); bx++) {
    const pixels = []
    for (let py = 0; py < 4; py++) for (let px = 0; px < 4; px++) {
      const x = Math.min(width - 1, bx * 4 + px)
      const y = Math.min(height - 1, by * 4 + py)
      const s = (y * width + x) * 4
      pixels.push([rgba[s], rgba[s + 1], rgba[s + 2], rgba[s + 3]])
    }
    if (format === '3TXD') {
      for (let i = 0; i < 16; i += 2) {
        const a0 = Math.round(pixels[i][3] / 17)
        const a1 = Math.round(pixels[i + 1][3] / 17)
        out[dst + (i >>> 1)] = a0 | (a1 << 4)
      }
      dst += 8
    }
    encodeColorBlock(pixels).copy(out, dst)
    dst += 8
  }
  return out
}

function safeName(name) {
  return name.replace(/[^a-z0-9._-]+/gi, '_').replace(/^_+|_+$/g, '') || 'unnamed'
}

function textureList(datPath) {
  const buffer = fs.readFileSync(datPath)
  return { buffer, textures: readBlocks(buffer).map(b => parseTexture(buffer, b)).filter(Boolean) }
}

function smoothstep(a, b, value) {
  const t = Math.max(0, Math.min(1, (value - a) / (b - a)))
  return t * t * (3 - 2 * t)
}

function sandWeight(r, g, b, alpha) {
  const max = Math.max(r, g, b), min = Math.min(r, g, b)
  const saturation = max ? (max - min) / max : 0
  const warmRed = smoothstep(0.015, 0.09, (r - b) / 255)
  const warmGreen = smoothstep(-0.005, 0.055, (g - b) / 255)
  const notGreen = 1 - smoothstep(-0.01, 0.04, (g - r) / 255)
  const notGray = smoothstep(0.025, 0.12, saturation)
  const notOrange = 1 - smoothstep(0.48, 0.7, saturation)
  const brightEnough = smoothstep(28, 85, max)
  return warmRed * warmGreen * notGreen * notGray * notOrange * brightEnough
}

function strictSandWeight(r, g, b, alpha) {
  const max = Math.max(r, g, b), min = Math.min(r, g, b)
  const saturation = max ? (max - min) / max : 0
  const redLead = smoothstep(0.025, 0.075, (r - g) / 255)
  const greenLead = smoothstep(0.015, 0.08, (g - b) / 255)
  const notOrange = 1 - smoothstep(0.46, 0.68, saturation)
  const brightEnough = smoothstep(64, 138, max)
  return redLead * greenLead * notOrange * brightEnough
}

function parseRegions(spec, width, height) {
  if (spec === 'none') return []
  if (!spec || spec === 'full') return [{ x0: 0, y0: 0, x1: width, y1: height }]
  return spec.split(';').map(value => {
    const [x0, y0, x1, y1] = value.split(',').map(Number)
    if (![x0, y0, x1, y1].every(Number.isFinite)) throw new Error(`Invalid region: ${value}`)
    return { x0, y0, x1, y1 }
  })
}

function inRegions(x, y, regions) {
  return regions.some(r => x >= r.x0 && y >= r.y0 && x < r.x1 && y < r.y1)
}

function weightedStats(image, regions, weightFunction = sandWeight) {
  const sums = [0, 0, 0], squares = [0, 0, 0]
  let total = 0
  for (let y = 0; y < image.height; y++) for (let x = 0; x < image.width; x++) {
    if (!inRegions(x, y, regions)) continue
    const p = (y * image.width + x) * 4
    const weight = weightFunction(image.rgba[p], image.rgba[p + 1], image.rgba[p + 2], image.rgba[p + 3])
    if (!weight) continue
    total += weight
    for (let c = 0; c < 3; c++) {
      const value = image.rgba[p + c]
      sums[c] += value * weight
      squares[c] += value * value * weight
    }
  }
  if (total < 1) throw new Error('No sand-colored pixels found')
  const mean = sums.map(v => v / total)
  const deviation = squares.map((v, c) => Math.sqrt(Math.max(1, v / total - mean[c] * mean[c])))
  return { mean, deviation, total }
}

function sandCoverage(image, regions, radius, weightFunction = sandWeight) {
  const width = image.width, height = image.height
  const stride = width + 1
  const integral = new Float64Array((width + 1) * (height + 1))
  for (let y = 0; y < height; y++) {
    let row = 0
    for (let x = 0; x < width; x++) {
      const p = (y * width + x) * 4
      const seed = inRegions(x, y, regions)
        ? smoothstep(0.12, 0.42, weightFunction(image.rgba[p], image.rgba[p + 1], image.rgba[p + 2], image.rgba[p + 3]))
        : 0
      row += seed
      integral[(y + 1) * stride + x + 1] = integral[y * stride + x + 1] + row
    }
  }

  const coverage = new Float32Array(width * height)
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) {
    if (!inRegions(x, y, regions)) continue
    const x0 = Math.max(0, x - radius), y0 = Math.max(0, y - radius)
    const x1 = Math.min(width, x + radius + 1), y1 = Math.min(height, y + radius + 1)
    const sum = integral[y1 * stride + x1] - integral[y0 * stride + x1] - integral[y1 * stride + x0] + integral[y0 * stride + x0]
    coverage[y * width + x] = sum / ((x1 - x0) * (y1 - y0))
  }
  return coverage
}

function neutralTerrainGate(r, g, b) {
  const max = Math.max(r, g, b)
  const strongGreen = smoothstep(0.025, 0.12, (g - r) / 255)
  const strongBlue = smoothstep(0.02, 0.11, (b - r) / 255)
  return (1 - strongGreen) * (1 - strongBlue) * smoothstep(24, 72, max)
}

function gradeSand(source, styleSource, styleTarget, regions, coverageRadius = 0, normalizeSource = false, weightFunction = sandWeight, strength = 1) {
  const sourceStats = weightedStats(source, regions, weightFunction)
  const styleSourceRegions = [{ x0: 0, y0: 0, x1: styleSource.width, y1: styleSource.height }]
  const styleTargetRegions = [{ x0: 0, y0: 0, x1: styleTarget.width, y1: styleTarget.height }]
  const styleSourceStats = weightedStats(styleSource, styleSourceRegions, weightFunction)
  const styleTargetStats = weightedStats(styleTarget, styleTargetRegions, weightFunction)
  const output = Buffer.from(source.rgba)
  const mask = Buffer.alloc(source.rgba.length)
  const coverage = coverageRadius > 0 ? sandCoverage(source, regions, coverageRadius, weightFunction) : null
  const referenceStats = normalizeSource ? sourceStats : styleSourceStats
  const scales = referenceStats.deviation.map((value, c) => Math.max(0.78, Math.min(1.22, styleTargetStats.deviation[c] / value)))
  let changed = 0
  for (let y = 0; y < source.height; y++) for (let x = 0; x < source.width; x++) {
    const p = (y * source.width + x) * 4
    let weight = inRegions(x, y, regions)
      ? weightFunction(source.rgba[p], source.rgba[p + 1], source.rgba[p + 2], source.rgba[p + 3])
      : 0
    weight = smoothstep(0.015, 0.3, weight)
    if (coverage) {
      const areaWeight = smoothstep(0.08, 0.36, coverage[y * source.width + x])
        * neutralTerrainGate(source.rgba[p], source.rgba[p + 1], source.rgba[p + 2])
      weight = Math.max(weight, areaWeight)
    }
    const maskValue = Math.round(weight * 255)
    mask[p] = maskValue; mask[p + 1] = maskValue; mask[p + 2] = maskValue; mask[p + 3] = 255
    if (weight < 0.01) continue
    changed++
    for (let c = 0; c < 3; c++) {
      const sourceValue = source.rgba[p + c]
      const graded = styleTargetStats.mean[c] + (sourceValue - referenceStats.mean[c]) * scales[c]
      output[p + c] = Math.round(Math.max(0, Math.min(255, sourceValue + (graded - sourceValue) * weight * strength)))
    }
  }
  return { rgba: output, mask, changed, sourceStats, styleSourceStats, styleTargetStats }
}

function toneImage(source, brightness, warmth) {
  const output = Buffer.from(source.rgba)
  for (let p = 0; p < output.length; p += 4) {
    output[p] = Math.round(Math.max(0, Math.min(255, source.rgba[p] * brightness + warmth)))
    output[p + 1] = Math.round(Math.max(0, Math.min(255, source.rgba[p + 1] * brightness + warmth * 0.65)))
    output[p + 2] = Math.round(Math.max(0, Math.min(255, source.rgba[p + 2] * brightness - warmth * 0.2)))
  }
  return output
}

function foliageWeight(r, g, b, alpha) {
  const max = Math.max(r, g, b), min = Math.min(r, g, b)
  const saturation = max ? (max - min) / max : 0
  const visible = smoothstep(0, 64, alpha)
  const greenLead = smoothstep(-0.005, 0.055, (g - r) / 255)
  const greenBlueLead = smoothstep(0, 0.08, (g - b) / 255)
  const colorful = smoothstep(0.035, 0.18, saturation)
  const brightEnough = smoothstep(18, 90, max)
  return visible * greenLead * greenBlueLead * colorful * brightEnough
}

function tropicalize(source, leafRegions, barkRegions) {
  const output = Buffer.from(source.rgba)
  const mask = Buffer.alloc(source.rgba.length)
  let leafPixels = 0, barkPixels = 0
  for (let y = 0; y < source.height; y++) for (let x = 0; x < source.width; x++) {
    const p = (y * source.width + x) * 4
    const r = source.rgba[p], g = source.rgba[p + 1], b = source.rgba[p + 2]
    const leafWeight = inRegions(x, y, leafRegions) ? foliageWeight(r, g, b, source.rgba[p + 3]) : 0
    const barkWeight = inRegions(x, y, barkRegions) ? 1 : 0
    if (leafWeight > 0.01) {
      leafPixels++
      const light = (r * 0.299 + g * 0.587 + b * 0.114) / 255
      const highlight = smoothstep(0.42, 0.78, light)
      const shadow = 1 - smoothstep(0.16, 0.46, light)
      const target = [
        r * 1.01 + highlight * 3,
        g * 1.085 + 3 + highlight * 4 - shadow * 2,
        b * 0.92 - 1,
      ]
      for (let c = 0; c < 3; c++) output[p + c] = Math.round(Math.max(0, Math.min(255, output[p + c] + (target[c] - output[p + c]) * leafWeight)))
    }
    if (barkWeight) {
      barkPixels++
      const target = [r * 1.055 + 5, g * 1.025 + 2, b * 0.945 - 2]
      for (let c = 0; c < 3; c++) output[p + c] = Math.round(Math.max(0, Math.min(255, output[p + c] + (target[c] - output[p + c]) * barkWeight)))
    }
    mask[p] = Math.round(barkWeight * 235)
    mask[p + 1] = Math.round(leafWeight * 255 + barkWeight * 120)
    mask[p + 2] = Math.round(leafWeight * 80)
    mask[p + 3] = 255
  }
  return { rgba: output, mask, leafPixels, barkPixels }
}

function main() {
  const [command, datPath, ...args] = process.argv.slice(2)
  if (!command || !datPath) throw new Error('Usage: list|extract|replace <DAT> [arguments]')
  if (command === 'grade-bmp') {
    const [styleSourcePath, styleTargetPath, outputPath, regionSpec = 'full', maskPath] = args
    if (!styleSourcePath || !styleTargetPath || !outputPath) throw new Error('Usage: grade-bmp <source.bmp> <style-source.bmp> <style-target.bmp> <output.bmp> [regions] [mask.bmp]')
    const source = readBmp(datPath)
    const styleSource = readBmp(styleSourcePath)
    const styleTarget = readBmp(styleTargetPath)
    const regions = parseRegions(regionSpec, source.width, source.height)
    const result = gradeSand(source, styleSource, styleTarget, regions)
    writeBmp(outputPath, source.width, source.height, result.rgba)
    if (maskPath) writeBmp(maskPath, source.width, source.height, result.mask)
    console.log(`Graded ${result.changed} sand pixels in ${outputPath}`)
    console.log(`Texture sand mean: ${result.sourceStats.mean.map(v => v.toFixed(1)).join(', ')}; style mapping: ${result.styleSourceStats.mean.map(v => v.toFixed(1)).join(', ')} -> ${result.styleTargetStats.mean.map(v => v.toFixed(1)).join(', ')}`)
    return
  }
  if (command === 'tone-bmp') {
    const [outputPath, rawBrightness = '1.06', rawWarmth = '4'] = args
    if (!outputPath) throw new Error('Usage: tone-bmp <source.bmp> <output.bmp> [brightness] [warmth]')
    const source = readBmp(datPath)
    const brightness = Number(rawBrightness), warmth = Number(rawWarmth)
    if (!Number.isFinite(brightness) || brightness < 0.5 || brightness > 1.5) throw new Error('Brightness must be from 0.5 to 1.5')
    if (!Number.isFinite(warmth) || warmth < -64 || warmth > 64) throw new Error('Warmth must be from -64 to 64')
    writeBmp(outputPath, source.width, source.height, toneImage(source, brightness, warmth))
    console.log(`Toned ${outputPath} with brightness ${brightness} and warmth ${warmth}`)
    return
  }
  if (command === 'tropical-bmp') {
    const [outputPath, leafRegionSpec = 'full', barkRegionSpec = 'none', maskPath] = args
    if (!outputPath) throw new Error('Usage: tropical-bmp <source.bmp> <output.bmp> [leaf-regions] [bark-regions] [mask.bmp]')
    const source = readBmp(datPath)
    const leafRegions = parseRegions(leafRegionSpec, source.width, source.height)
    const barkRegions = parseRegions(barkRegionSpec, source.width, source.height)
    const result = tropicalize(source, leafRegions, barkRegions)
    writeBmp(outputPath, source.width, source.height, result.rgba)
    if (maskPath) writeBmp(maskPath, source.width, source.height, result.mask)
    console.log(`Tropicalized ${result.leafPixels} leaf pixels and ${result.barkPixels} bark pixels in ${outputPath}`)
    return
  }
  if (command === 'grade-bmp-all-sand') {
    const [styleSourcePath, styleTargetPath, outputPath, regionSpec = 'full', maskPath, rawRadius = '10'] = args
    if (!styleSourcePath || !styleTargetPath || !outputPath) throw new Error('Usage: grade-bmp-all-sand <source.bmp> <style-source.bmp> <style-target.bmp> <output.bmp> [regions] [mask.bmp] [radius]')
    const source = readBmp(datPath)
    const styleSource = readBmp(styleSourcePath)
    const styleTarget = readBmp(styleTargetPath)
    const regions = parseRegions(regionSpec, source.width, source.height)
    const radius = Number(rawRadius)
    if (!Number.isInteger(radius) || radius < 1 || radius > 64) throw new Error('Coverage radius must be an integer from 1 to 64')
    const result = gradeSand(source, styleSource, styleTarget, regions, radius, true)
    writeBmp(outputPath, source.width, source.height, result.rgba)
    if (maskPath) writeBmp(maskPath, source.width, source.height, result.mask)
    console.log(`Graded ${result.changed} continuous sand pixels in ${outputPath}`)
    console.log(`Texture sand mean: ${result.sourceStats.mean.map(v => v.toFixed(1)).join(', ')}; style mapping: ${result.styleSourceStats.mean.map(v => v.toFixed(1)).join(', ')} -> ${result.styleTargetStats.mean.map(v => v.toFixed(1)).join(', ')}`)
    return
  }
  if (command === 'grade-bmp-sand-match') {
    const [styleSourcePath, styleTargetPath, outputPath, regionSpec = 'full', maskPath, rawRadius = '3', rawStrength = '1'] = args
    if (!styleSourcePath || !styleTargetPath || !outputPath) throw new Error('Usage: grade-bmp-sand-match <source.bmp> <style-source.bmp> <style-target.bmp> <output.bmp> [regions] [mask.bmp] [radius] [strength]')
    const source = readBmp(datPath)
    const styleSource = readBmp(styleSourcePath)
    const styleTarget = readBmp(styleTargetPath)
    const regions = parseRegions(regionSpec, source.width, source.height)
    const radius = Number(rawRadius)
    if (!Number.isInteger(radius) || radius < 1 || radius > 64) throw new Error('Coverage radius must be an integer from 1 to 64')
    const strength = Number(rawStrength)
    if (!Number.isFinite(strength) || strength < 0 || strength > 1) throw new Error('Strength must be from 0 to 1')
    const result = gradeSand(source, styleSource, styleTarget, regions, radius, true, strictSandWeight, strength)
    writeBmp(outputPath, source.width, source.height, result.rgba)
    if (maskPath) writeBmp(maskPath, source.width, source.height, result.mask)
    console.log(`Matched ${result.changed} strict sand pixels in ${outputPath} at ${strength} strength`)
    console.log(`Texture sand mean: ${result.sourceStats.mean.map(v => v.toFixed(1)).join(', ')}; target: ${result.styleTargetStats.mean.map(v => v.toFixed(1)).join(', ')}`)
    return
  }
  const { buffer, textures } = textureList(datPath)
  if (command === 'verify') {
    const modifiedPath = args[0]
    if (!modifiedPath) throw new Error('Usage: verify <original.DAT> <modified.DAT>')
    const modified = textureList(modifiedPath)
    if (buffer.length !== modified.buffer.length) throw new Error('DAT file sizes differ')
    if (textures.length !== modified.textures.length) throw new Error('Texture counts differ')
    const changedTextureRows = []
    for (let i = 0; i < textures.length; i++) {
      const a = textures[i], b = modified.textures[i]
      for (const key of ['offset', 'id', 'flag', 'width', 'height', 'format', 'pixelOffset', 'pixelSize']) {
        if (a[key] !== b[key]) throw new Error(`Texture ${i} metadata differs at ${key}`)
      }
      let colorChanged = false
      if (a.format === '3TXD') {
        for (let p = 0; p < a.pixelSize; p += 16) {
          for (let j = 0; j < 8; j++) {
            if (buffer[a.pixelOffset + p + j] !== modified.buffer[b.pixelOffset + p + j]) {
              throw new Error(`Texture ${i} alpha data differs at block ${p / 16}`)
            }
          }
          for (let j = 8; j < 16; j++) colorChanged ||= buffer[a.pixelOffset + p + j] !== modified.buffer[b.pixelOffset + p + j]
        }
      } else {
        for (let p = 0; p < a.pixelSize; p++) colorChanged ||= buffer[a.pixelOffset + p] !== modified.buffer[b.pixelOffset + p]
      }
      if (colorChanged) changedTextureRows.push(`${i}:${a.name.trim()}/${a.id.trim()}`)
    }
    console.log(`Verified: same size, ${textures.length} textures, unchanged texture metadata and DXT3 alpha; ${changedTextureRows.length} color textures changed`)
    if (changedTextureRows.length) console.log(`Changed textures: ${changedTextureRows.join(', ')}`)
    return
  }
  if (command === 'list') {
    console.table(textures.map(t => ({ index: t.index, block: t.name, id: t.id, width: t.width, height: t.height, format: t.format, offset: `0x${t.offset.toString(16)}` })))
    return
  }
  if (command === 'sand-score') {
    const rows = textures.map((texture, ordinal) => {
      let weighted = 0, candidates = 0
      for (let p = 0; p < texture.rgba.length; p += 4) {
        const weight = sandWeight(texture.rgba[p], texture.rgba[p + 1], texture.rgba[p + 2], texture.rgba[p + 3])
        weighted += weight
        if (weight >= 0.3) candidates++
      }
      return { ordinal, block: texture.name, id: texture.id, size: `${texture.width}x${texture.height}`, weighted: Math.round(weighted), candidates, percent: (100 * candidates / (texture.width * texture.height)).toFixed(1) }
    }).filter(row => row.candidates > 0).sort((a, b) => b.candidates - a.candidates)
    console.table(rows)
    return
  }
  if (command === 'sand-stats') {
    const rows = []
    for (let ordinal = 0; ordinal < textures.length; ordinal++) {
      const texture = textures[ordinal]
      try {
        const regions = [{ x0: 0, y0: 0, x1: texture.width, y1: texture.height }]
        const stats = weightedStats(texture, regions, strictSandWeight)
        rows.push({
          ordinal,
          block: texture.name,
          id: texture.id,
          size: `${texture.width}x${texture.height}`,
          mean: stats.mean.map(v => v.toFixed(1)).join(', '),
          deviation: stats.deviation.map(v => v.toFixed(1)).join(', '),
          weight: Math.round(stats.total),
        })
      } catch {}
    }
    console.table(rows.sort((a, b) => b.weight - a.weight))
    return
  }
  if (command === 'extract') {
    const outDir = args[0]
    if (!outDir) throw new Error('Usage: extract <DAT> <output directory>')
    fs.mkdirSync(outDir, { recursive: true })
    const manifest = []
    for (let i = 0; i < textures.length; i++) {
      const t = textures[i]
      const file = `${String(i).padStart(3, '0')}_${safeName(t.name)}_${safeName(t.id)}_${t.width}x${t.height}_${t.format}.bmp`
      writeBmp(path.join(outDir, file), t.width, t.height, t.rgba)
      manifest.push({ ordinal: i, file, blockIndex: t.index, blockName: t.name, id: t.id, width: t.width, height: t.height, format: t.format, blockOffset: t.offset, pixelOffset: t.pixelOffset, pixelSize: t.pixelSize })
    }
    fs.writeFileSync(path.join(outDir, 'textures.json'), JSON.stringify(manifest, null, 2))
    console.log(`Extracted ${textures.length} textures to ${outDir}`)
    return
  }
  if (command === 'replace-many') {
    const [outputPath, ...pairs] = args
    if (!outputPath || pairs.length < 2 || pairs.length % 2) throw new Error('Usage: replace-many <DAT> <output.DAT> <ordinal|id> <replacement.bmp> [...]')
    const output = Buffer.from(buffer)
    const replaced = []
    for (let pair = 0; pair < pairs.length; pair += 2) {
      const selector = pairs[pair]
      const replacementPath = pairs[pair + 1]
      const ordinal = Number(selector)
      const matches = Number.isInteger(ordinal) && String(ordinal) === selector
        ? [textures[ordinal]].filter(Boolean)
        : textures.filter(t => t.id === selector)
      if (matches.length !== 1) throw new Error(`Selector ${selector} matched ${matches.length} textures`)
      const texture = matches[0]
      if (!['1TXD', '3TXD'].includes(texture.format)) throw new Error(`Replacement for ${texture.format} textures is not supported`)
      const replacement = readBmp(replacementPath)
      if (replacement.width !== texture.width || replacement.height !== texture.height) {
        throw new Error(`Replacement ${selector} is ${replacement.width}x${replacement.height}; expected ${texture.width}x${texture.height}`)
      }
      for (let i = 3; i < replacement.rgba.length; i += 4) replacement.rgba[i] = texture.rgba[i]
      const compressed = encodeDxt(replacement.rgba, replacement.width, replacement.height, texture.format)
      if (compressed.length !== texture.pixelSize) throw new Error(`Compressed size ${compressed.length} does not match ${texture.pixelSize}`)
      compressed.copy(output, texture.pixelOffset)
      replaced.push(`${selector}:${texture.id}`)
    }
    fs.writeFileSync(outputPath, output)
    console.log(`Replaced ${replaced.length} textures in ${outputPath}`)
    console.log(replaced.join('\n'))
    return
  }
  if (command === 'replace') {
    const [selector, replacementPath, outputPath] = args
    if (!selector || !replacementPath || !outputPath) throw new Error('Usage: replace <DAT> <ordinal|id> <replacement.bmp> <output.DAT>')
    const ordinal = Number(selector)
    const matches = Number.isInteger(ordinal) && String(ordinal) === selector
      ? [textures[ordinal]].filter(Boolean)
      : textures.filter(t => t.id === selector)
    if (matches.length !== 1) throw new Error(`Selector matched ${matches.length} textures; use the extraction ordinal for an exact match`)
    const texture = matches[0]
    if (!['1TXD', '3TXD'].includes(texture.format)) throw new Error(`Replacement for ${texture.format} textures is not supported`)
    const replacement = readBmp(replacementPath)
    if (replacement.width !== texture.width || replacement.height !== texture.height) {
      throw new Error(`Replacement is ${replacement.width}x${replacement.height}; expected ${texture.width}x${texture.height}`)
    }
    for (let i = 3; i < replacement.rgba.length; i += 4) replacement.rgba[i] = texture.rgba[i]
    const compressed = encodeDxt(replacement.rgba, replacement.width, replacement.height, texture.format)
    if (compressed.length !== texture.pixelSize) throw new Error(`Compressed size ${compressed.length} does not match ${texture.pixelSize}`)
    const output = Buffer.from(buffer)
    compressed.copy(output, texture.pixelOffset)
    fs.writeFileSync(outputPath, output)
    console.log(`Replaced texture ${selector} (${texture.id}, ${texture.width}x${texture.height}, ${texture.format}) in ${outputPath}`)
    return
  }
  throw new Error(`Unknown command: ${command}`)
}

main()
