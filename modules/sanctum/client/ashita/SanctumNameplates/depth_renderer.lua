if addon == nil then
    return {}
end

require 'common'

local ffi = require 'ffi'

local renderer = {}

ffi.cdef[[
    typedef struct {
        float x, y, z;
        unsigned int color;
    } snp_d3d_vertex_t;

    typedef struct {
        float x, y, z;
        unsigned int color;
        float tu, tv;
    } snp_d3d_textured_vertex_t;
]]

local D3DPT_TRIANGLELIST = 4
local D3DFVF_XYZ_DIFFUSE = 0x042
local D3DFVF_XYZ_DIFFUSE_TEX1 = 0x142
local VERTEX_SIZE = 16
local TEXTURED_VERTEX_SIZE = 24

local D3DRS_ZENABLE = 7
local D3DRS_ZWRITEENABLE = 14
local D3DRS_ALPHATESTENABLE = 15
local D3DRS_SRCBLEND = 19
local D3DRS_DESTBLEND = 20
local D3DRS_CULLMODE = 22
local D3DRS_ZFUNC = 23
local D3DRS_ALPHAREF = 24
local D3DRS_ALPHAFUNC = 25
local D3DRS_ALPHABLENDENABLE = 27
local D3DRS_ZBIAS = 47
local D3DRS_LIGHTING = 137

local D3DCMP_LESSEQUAL = 4
local D3DCMP_GREATEREQUAL = 7

local D3DTSS_COLOROP = 1
local D3DTSS_COLORARG1 = 2
local D3DTSS_COLORARG2 = 3
local D3DTSS_ALPHAOP = 4
local D3DTSS_ALPHAARG1 = 5
local D3DTSS_ALPHAARG2 = 6
local D3DTSS_ADDRESSU = 13
local D3DTSS_ADDRESSV = 14
local D3DTSS_MAGFILTER = 16
local D3DTSS_MINFILTER = 17

local D3DTOP_DISABLE = 1
local D3DTOP_SELECTARG1 = 2
local D3DTOP_MODULATE = 4
local D3DTA_DIFFUSE = 0
local D3DTA_TEXTURE = 2
local D3DTEXF_LINEAR = 2
local D3DTADDRESS_CLAMP = 3
local D3DTS_WORLD = 256

local MAX_TEXT_CHARS = 96
local text_vertices = ffi.new('snp_d3d_textured_vertex_t[?]', MAX_TEXT_CHARS * 6)
local color_vertices = ffi.new('snp_d3d_vertex_t[6]')

local identity_matrix = ffi.new('D3DMATRIX')
identity_matrix._11 = 1
identity_matrix._22 = 1
identity_matrix._33 = 1
identity_matrix._44 = 1

local ortho_matrix = ffi.new('D3DMATRIX')
local restore_world = ffi.new('D3DMATRIX')
local restore_view = ffi.new('D3DMATRIX')
local restore_projection = ffi.new('D3DMATRIX')

local outline_offsets = {
    { -1, -1 }, { 0, -1 }, { 1, -1 },
    { -1,  0 },            { 1,  0 },
    { -1,  1 }, { 0,  1 }, { 1,  1 },
}

local rare_twinkle_points = {
    { -0.02, 0.42, 0.00 },
    {  0.18, -0.18, 0.85 },
    {  0.36, 1.18, 1.70 },
    {  0.58, -0.16, 2.55 },
    {  0.79, 1.20, 3.40 },
    {  1.02, 0.55, 4.25 },
    {  0.93, -0.10, 5.10 },
    {  0.06, 1.10, 5.95 },
}

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function pack_color(red, green, blue, alpha)
    local r = math.floor(clamp(red, 0, 1) * 255 + 0.5)
    local g = math.floor(clamp(green, 0, 1) * 255 + 0.5)
    local b = math.floor(clamp(blue, 0, 1) * 255 + 0.5)
    local a = math.floor(clamp(alpha, 0, 1) * 255 + 0.5)
    return a * 0x1000000 + r * 0x10000 + g * 0x100 + b
end

local function pack_config_color(config, key, alpha)
    return pack_color(
        config[key .. '_color_r'],
        config[key .. '_color_g'],
        config[key .. '_color_b'],
        alpha)
end

local function copy_matrix(matrix)
    return {
        _11 = matrix._11, _12 = matrix._12, _13 = matrix._13, _14 = matrix._14,
        _21 = matrix._21, _22 = matrix._22, _23 = matrix._23, _24 = matrix._24,
        _31 = matrix._31, _32 = matrix._32, _33 = matrix._33, _34 = matrix._34,
        _41 = matrix._41, _42 = matrix._42, _43 = matrix._43, _44 = matrix._44,
    }
end

local function table_to_matrix(source, target)
    target._11 = source._11; target._12 = source._12; target._13 = source._13; target._14 = source._14
    target._21 = source._21; target._22 = source._22; target._23 = source._23; target._24 = source._24
    target._31 = source._31; target._32 = source._32; target._33 = source._33; target._34 = source._34
    target._41 = source._41; target._42 = source._42; target._43 = source._43; target._44 = source._44
    return target
end

local function get_baked_font(font, size)
    local ok, baked = pcall(function()
        return font:GetFontBaked(size, 1.0)
    end)
    if not ok or baked == nil then
        return nil
    end
    local glyph_ok, glyph = pcall(function()
        return baked:FindGlyph(65)
    end)
    if not glyph_ok or glyph == nil then
        return nil
    end
    return baked
end

local function get_font_texture(font)
    local atlas = font ~= nil and font.ContainerAtlas or nil
    local texture_reference = atlas ~= nil and atlas.TexRef or nil
    if texture_reference == nil then
        return nil
    end

    local ok, texture_id = pcall(function()
        return texture_reference:GetTexID()
    end)
    if not ok or texture_id == nil or texture_id == 0 then
        ok, texture_id = pcall(function()
            return texture_reference._TexID
        end)
    end
    if not ok or texture_id == nil or texture_id == 0 then
        return nil
    end

    local cast_ok, texture = pcall(function()
        return ffi.cast('IDirect3DBaseTexture8*', ffi.cast('uintptr_t', texture_id))
    end)
    if not cast_ok or texture == nil or texture == ffi.NULL then
        return nil
    end
    return texture
end

local function measure_text(baked, text)
    local width = 0
    local count = math.min(#text, MAX_TEXT_CHARS)
    for index = 1, count do
        local glyph = baked:FindGlyph(string.byte(text, index))
        if glyph ~= nil then
            width = width + glyph.AdvanceX
        end
    end
    return width
end

local function build_text(baked, text, color, x, y, depth)
    local vertex_index = 0
    local cursor_x = 0
    local count = math.min(#text, MAX_TEXT_CHARS)

    for index = 1, count do
        local glyph = baked:FindGlyph(string.byte(text, index))
        if glyph ~= nil then
            if glyph.X1 > glyph.X0 and glyph.Y1 > glyph.Y0 then
                local x0 = x + cursor_x + glyph.X0
                local y0 = y + glyph.Y0
                local x1 = x + cursor_x + glyph.X1
                local y1 = y + glyph.Y1

                text_vertices[vertex_index].x = x0
                text_vertices[vertex_index].y = y0
                text_vertices[vertex_index].z = depth
                text_vertices[vertex_index].color = color
                text_vertices[vertex_index].tu = glyph.U0
                text_vertices[vertex_index].tv = glyph.V0

                text_vertices[vertex_index + 1].x = x1
                text_vertices[vertex_index + 1].y = y0
                text_vertices[vertex_index + 1].z = depth
                text_vertices[vertex_index + 1].color = color
                text_vertices[vertex_index + 1].tu = glyph.U1
                text_vertices[vertex_index + 1].tv = glyph.V0

                text_vertices[vertex_index + 2].x = x0
                text_vertices[vertex_index + 2].y = y1
                text_vertices[vertex_index + 2].z = depth
                text_vertices[vertex_index + 2].color = color
                text_vertices[vertex_index + 2].tu = glyph.U0
                text_vertices[vertex_index + 2].tv = glyph.V1

                text_vertices[vertex_index + 3] = text_vertices[vertex_index + 1]

                text_vertices[vertex_index + 4].x = x1
                text_vertices[vertex_index + 4].y = y1
                text_vertices[vertex_index + 4].z = depth
                text_vertices[vertex_index + 4].color = color
                text_vertices[vertex_index + 4].tu = glyph.U1
                text_vertices[vertex_index + 4].tv = glyph.V1

                text_vertices[vertex_index + 5] = text_vertices[vertex_index + 2]
                vertex_index = vertex_index + 6
            end
            cursor_x = cursor_x + glyph.AdvanceX
        end
    end
    return vertex_index
end

local function draw_text(device, baked, text, color, x, y, depth)
    local vertex_count = build_text(baked, text, color, x, y, depth)
    if vertex_count > 0 then
        device:DrawPrimitiveUP(
            D3DPT_TRIANGLELIST, vertex_count / 3, text_vertices, TEXTURED_VERTEX_SIZE)
    end
end

local function draw_outlined_text(device, baked, text, color, x, y, depth, width, alpha)
    if width > 0 then
        local outline = pack_color(0, 0, 0, alpha)
        for _, offset in ipairs(outline_offsets) do
            draw_text(device, baked, text, outline,
                x + offset[1] * width, y + offset[2] * width, depth)
        end
    end
    draw_text(device, baked, text, color, x, y, depth)
end

local function set_color_vertex(index, x, y, depth, color)
    color_vertices[index].x = x
    color_vertices[index].y = y
    color_vertices[index].z = depth
    color_vertices[index].color = color
end

local function draw_quad(device, x0, y0, x1, y1, depth, color)
    set_color_vertex(0, x0, y0, depth, color)
    set_color_vertex(1, x1, y0, depth, color)
    set_color_vertex(2, x0, y1, depth, color)
    color_vertices[3] = color_vertices[1]
    set_color_vertex(4, x1, y1, depth, color)
    color_vertices[5] = color_vertices[2]
    device:DrawPrimitiveUP(D3DPT_TRIANGLELIST, 2, color_vertices, VERTEX_SIZE)
end

local function draw_line(device, x0, y0, x1, y1, depth, color, thickness)
    local dx = x1 - x0
    local dy = y1 - y0
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0.001 then
        return
    end
    local offset_x = -dy / length * thickness / 2
    local offset_y = dx / length * thickness / 2

    set_color_vertex(0, x0 + offset_x, y0 + offset_y, depth, color)
    set_color_vertex(1, x1 + offset_x, y1 + offset_y, depth, color)
    set_color_vertex(2, x0 - offset_x, y0 - offset_y, depth, color)
    color_vertices[3] = color_vertices[1]
    set_color_vertex(4, x1 - offset_x, y1 - offset_y, depth, color)
    color_vertices[5] = color_vertices[2]
    device:DrawPrimitiveUP(D3DPT_TRIANGLELIST, 2, color_vertices, VERTEX_SIZE)
end

local function draw_glint(device, x, y, depth, radius, color)
    draw_line(device, x - radius, y, x + radius, y, depth, color, 1)
    draw_line(device, x, y - radius * 1.5, x, y + radius * 1.5, depth, color, 1)
    local diagonal = radius * 0.55
    draw_line(device, x - diagonal, y - diagonal,
        x + diagonal, y + diagonal, depth, color, 1)
    draw_line(device, x - diagonal, y + diagonal,
        x + diagonal, y - diagonal, depth, color, 1)
end

local function get_name_color(label, config)
    if label.targeted then
        return pack_color(
            config.target_color_r, config.target_color_g, config.target_color_b, label.alpha)
    end
    if label.kind == 'mob' then
        if label.engaged and label.claim_kind == 'party' then
            return pack_config_color(config, 'mob_engaged', label.alpha)
        elseif label.claim_kind == 'party' then
            return pack_config_color(config, 'mob_party_claimed', label.alpha)
        elseif label.claim_kind == 'other' then
            return pack_config_color(config, 'mob_other_claimed', label.alpha)
        end
        return pack_config_color(config, 'mob_unclaimed', label.alpha)
    end
    if label.kind == 'pet' then
        return pack_color(0.68, 0.82, 1.00, label.alpha)
    end
    if label.kind == 'npc' then
        return pack_color(0.58, 1.00, 0.66, label.alpha)
    end
    return pack_color(0.48, 0.86, 1.00, label.alpha)
end

local function get_difficulty_color(label, config)
    if label.difficulty_kind == nil then
        return get_name_color(label, config)
    end
    return pack_config_color(
        config, 'difficulty_' .. label.difficulty_kind, label.alpha)
end

local function get_hp_color(label, config)
    if label.targeted then
        return pack_config_color(config, 'target_hp_bar', label.alpha)
    end
    local percent = label.hp_percent
    local alpha = label.alpha
    local fraction = clamp(percent / 100, 0, 1)
    if fraction >= 0.5 then
        return pack_color((1 - fraction) * 2, 1, 0.12, alpha)
    end
    return pack_color(1, fraction * 2, 0.12, alpha)
end

local function get_rare_colors(rare_kind, alpha)
    if rare_kind == 'chainbreaker' then
        return pack_color(1.00, 0.38, 0.05, alpha),
            pack_color(1.00, 1.00, 0.55, alpha)
    end
    return pack_color(0.55, 0.28, 1.00, alpha),
        pack_color(0.72, 1.00, 1.00, alpha)
end

local function prepare_layouts(labels, font, config, viewport)
    local baked_by_size = {}
    local layouts = {}
    local viewport_left = tonumber(viewport.X) or 0
    local viewport_width = tonumber(viewport.Width) or 0

    local function get_baked(size)
        local baked = baked_by_size[size]
        if baked == nil then
            baked = get_baked_font(font, size)
            baked_by_size[size] = baked
        end
        return baked
    end

    for _, label in ipairs(labels) do
        local baked = get_baked(label.font_size)
        if baked == nil then
            return nil, 'The selected font could not be baked for depth rendering.'
        end

        local width = measure_text(baked, label.text)
        local height = label.font_size
        local layout = {
            label = label,
            baked = baked,
            text_width = width,
            text_height = height,
            x = math.floor(label.x - width / 2 + 0.5),
            y = math.floor(label.y - height - 2 + 0.5),
        }

        if label.level_text ~= nil then
            layout.level_width = measure_text(baked, label.level_text)
            layout.separator_width = measure_text(baked, '  ')
            layout.name_x = layout.x + layout.level_width + layout.separator_width
        end

        if label.hp_percent ~= nil then
            local bar_width = label.targeted
                and config.target_hp_bar_width or config.hp_bar_width
            local bar_height = label.targeted
                and config.target_hp_bar_height or config.hp_bar_height
            layout.bar_width = bar_width
            layout.bar_height = bar_height
            layout.bar_x = math.floor(label.x - bar_width / 2 + 0.5)
            layout.bar_y = math.floor(label.y + 1.5)

            if label.show_hp_percent then
                layout.hp_text = ('%d%%'):format(math.floor(label.hp_percent + 0.5))
                local hp_font_size = label.targeted
                    and config.target_hp_percent_font_size or config.hp_percent_font_size
                layout.hp_baked = get_baked(hp_font_size)
                if layout.hp_baked == nil then
                    return nil, 'The selected HP font could not be baked for depth rendering.'
                end
                layout.hp_width = measure_text(layout.hp_baked, layout.hp_text)
                layout.hp_height = hp_font_size
                if label.show_hp_bar then
                    layout.hp_x = layout.bar_x + bar_width + 5
                    if layout.hp_x + layout.hp_width > viewport_left + viewport_width then
                        layout.hp_x = layout.bar_x - layout.hp_width - 5
                    end
                else
                    layout.hp_x = label.x - layout.hp_width / 2
                end
                layout.hp_y = layout.bar_y + (layout.bar_height - layout.hp_height) / 2
            end
        end
        layouts[#layouts + 1] = layout
    end
    return layouts
end

local function get_layout_bounds(layout, shift)
    shift = shift or 0
    local left = layout.x - 3
    local right = layout.x + layout.text_width + 3
    local top = layout.y - shift - 4
    local bottom = layout.y - shift + layout.text_height + 3

    if layout.label.show_hp_bar then
        left = math.min(left, layout.bar_x - 2)
        right = math.max(right, layout.bar_x + layout.bar_width + 2)
        top = math.min(top, layout.bar_y - shift - 2)
        bottom = math.max(bottom, layout.bar_y - shift + layout.bar_height + 2)
    end
    if layout.hp_text ~= nil then
        left = math.min(left, layout.hp_x - 2)
        right = math.max(right, layout.hp_x + layout.hp_width + 2)
        top = math.min(top, layout.hp_y - shift - 2)
        bottom = math.max(bottom, layout.hp_y - shift + layout.hp_height + 2)
    end
    return { left = left, right = right, top = top, bottom = bottom }
end

local function bounds_overlap(left, right, spacing)
    return left.left < right.right + spacing
        and left.right > right.left - spacing
        and left.top < right.bottom + spacing
        and left.bottom > right.top - spacing
end

local function shift_layout(layout, amount)
    if amount <= 0 then
        return
    end
    layout.y = layout.y - amount
    if layout.bar_y ~= nil then
        layout.bar_y = layout.bar_y - amount
    end
    if layout.hp_y ~= nil then
        layout.hp_y = layout.hp_y - amount
    end
end

local function resolve_overlaps(layouts, config, viewport)
    if config.avoid_overlaps == false or #layouts < 2 then
        return
    end

    local placement_order = {}
    for _, layout in ipairs(layouts) do
        placement_order[#placement_order + 1] = layout
    end
    table.sort(placement_order, function(left, right)
        local left_label = left.label
        local right_label = right.label
        local left_priority = (left_label.targeted and 1000 or 0)
            + (left_label.engaged and 200 or 0)
            + (left_label.claim_kind == 'party' and 100 or 0)
        local right_priority = (right_label.targeted and 1000 or 0)
            + (right_label.engaged and 200 or 0)
            + (right_label.claim_kind == 'party' and 100 or 0)
        if left_priority ~= right_priority then
            return left_priority > right_priority
        end
        return left_label.distance < right_label.distance
    end)

    local occupied = {}
    local spacing = config.overlap_spacing
    local maximum_shift = config.overlap_max_shift
    local viewport_top = tonumber(viewport.Y) or 0

    for _, layout in ipairs(placement_order) do
        local original = get_layout_bounds(layout, 0)
        local shift = 0
        local placed = false

        for _ = 1, #occupied + 1 do
            local candidate = get_layout_bounds(layout, shift)
            local required_shift = shift
            local collision = false
            for _, used in ipairs(occupied) do
                if bounds_overlap(candidate, used, spacing) then
                    collision = true
                    required_shift = math.max(
                        required_shift, original.bottom - used.top + spacing)
                end
            end
            if not collision then
                placed = candidate.top >= viewport_top or layout.label.targeted
                break
            end
            shift = required_shift
            if shift > maximum_shift then
                break
            end
        end

        if placed and shift <= maximum_shift then
            shift_layout(layout, shift)
            occupied[#occupied + 1] = get_layout_bounds(layout, 0)
        else
            layout.label.alpha = layout.label.alpha * config.overlap_fade_alpha
        end
    end
end

local function set_colored_pipeline(device)
    device:SetTexture(0, nil)
    device:SetVertexShader(D3DFVF_XYZ_DIFFUSE)
    device:SetRenderState(D3DRS_ALPHATESTENABLE, 0)
    device:SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1)
    device:SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE)
    device:SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1)
    device:SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE)
end

local function set_text_pipeline(device, texture)
    device:SetTexture(0, texture)
    device:SetVertexShader(D3DFVF_XYZ_DIFFUSE_TEX1)
    device:SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1)
    device:SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE)
    device:SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE)
    device:SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE)
    device:SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE)
    device:SetTextureStageState(0, D3DTSS_MAGFILTER, D3DTEXF_LINEAR)
    device:SetTextureStageState(0, D3DTSS_MINFILTER, D3DTEXF_LINEAR)
    device:SetTextureStageState(0, D3DTSS_ADDRESSU, D3DTADDRESS_CLAMP)
    device:SetTextureStageState(0, D3DTSS_ADDRESSV, D3DTADDRESS_CLAMP)
    device:SetRenderState(D3DRS_ALPHATESTENABLE, 1)
    device:SetRenderState(D3DRS_ALPHAREF, 1)
    device:SetRenderState(D3DRS_ALPHAFUNC, D3DCMP_GREATEREQUAL)
end

local function draw_colored_pass(device, layouts, config, now)
    set_colored_pipeline(device)

    for _, layout in ipairs(layouts) do
        local label = layout.label
        if config.rare_glimmer ~= false and label.rare_kind ~= nil then
            local intensity = config.glimmer_intensity
            local point_count = label.rare_kind == 'chainbreaker' and 8 or 6
            for index = 1, point_count do
                local point = rare_twinkle_points[index]
                local wave = (math.sin(now * 4.4 + point[3] + label.rare_seed * 13) + 1) / 2
                local sparkle = wave * wave * wave * wave
                if sparkle > 0.04 then
                    local alpha = clamp(label.alpha * sparkle * intensity, 0, 1)
                    local glow, shine = get_rare_colors(label.rare_kind, alpha)
                    local color = index % 2 == 0 and shine or glow
                    local radius = (0.75 + sparkle * 1.35) * math.min(intensity, 1.3)
                    if label.rare_kind == 'chainbreaker' then
                        radius = radius * 1.15
                    end
                    draw_glint(device,
                        layout.x + layout.text_width * point[1],
                        layout.y + layout.text_height * point[2],
                        label.depth, radius, color)
                end
            end
        end

        if label.hp_percent ~= nil and label.show_hp_bar then
            draw_quad(device, layout.bar_x, layout.bar_y,
                layout.bar_x + layout.bar_width,
                layout.bar_y + layout.bar_height,
                label.depth, pack_color(0.02, 0.02, 0.02, label.alpha * 0.92))

            local fill_width = math.max(0,
                (layout.bar_width - 2) * label.hp_percent / 100)
            if fill_width > 0 then
                draw_quad(device, layout.bar_x + 1, layout.bar_y + 1,
                    layout.bar_x + 1 + fill_width,
                    layout.bar_y + layout.bar_height - 1,
                    label.depth, get_hp_color(label, config))
            end
        end
    end
end

local function draw_text_pass(device, layouts, texture, config, now)
    set_text_pipeline(device, texture)

    for _, layout in ipairs(layouts) do
        local label = layout.label
        if config.rare_glimmer ~= false and label.rare_kind ~= nil then
            local intensity = config.glimmer_intensity
            local pulse = 0.76 + 0.24 * math.sin(
                now * 2.4 + label.rare_seed * math.pi * 2)
            local alpha = clamp(label.alpha * 0.34 * intensity * pulse, 0, 1)
            local glow = get_rare_colors(label.rare_kind, alpha)
            local radius = label.rare_kind == 'chainbreaker' and 4 or 3
            local offsets = {
                { -radius, 0 }, { radius, 0 }, { 0, -radius }, { 0, radius },
                { -radius, -radius }, { radius, -radius },
                { -radius, radius }, { radius, radius },
            }
            for _, offset in ipairs(offsets) do
                draw_text(device, layout.baked, label.text, glow,
                    layout.x + offset[1], layout.y + offset[2], label.depth)
            end
        end

        local name_color = get_name_color(label, config)
        if config.difficulty_coloring == true
            and not label.targeted
            and label.level_text ~= nil
            and label.difficulty_kind ~= nil then
            draw_outlined_text(device, layout.baked, label.level_text,
                get_difficulty_color(label, config), layout.x, layout.y, label.depth,
                config.outline_width, label.alpha)
            draw_outlined_text(device, layout.baked, label.name_text,
                name_color, layout.name_x, layout.y, label.depth,
                config.outline_width, label.alpha)
        else
            draw_outlined_text(device, layout.baked, label.text,
                name_color, layout.x, layout.y, label.depth,
                config.outline_width, label.alpha)
        end

        if layout.hp_text ~= nil then
            local hp_text_color = label.targeted and name_color
                or pack_color(1, 1, 1, label.alpha)
            draw_outlined_text(device, layout.hp_baked, layout.hp_text,
                hp_text_color,
                math.floor(layout.hp_x + 0.5), math.floor(layout.hp_y + 0.5),
                label.depth, config.outline_width, label.alpha)
        end
    end
end

local function capture_state(device)
    local state = {}
    local ignored
    ignored, state.lighting = device:GetRenderState(D3DRS_LIGHTING)
    ignored, state.z_enable = device:GetRenderState(D3DRS_ZENABLE)
    ignored, state.z_write = device:GetRenderState(D3DRS_ZWRITEENABLE)
    ignored, state.z_function = device:GetRenderState(D3DRS_ZFUNC)
    ignored, state.z_bias = device:GetRenderState(D3DRS_ZBIAS)
    ignored, state.alpha_blend = device:GetRenderState(D3DRS_ALPHABLENDENABLE)
    ignored, state.source_blend = device:GetRenderState(D3DRS_SRCBLEND)
    ignored, state.destination_blend = device:GetRenderState(D3DRS_DESTBLEND)
    ignored, state.cull = device:GetRenderState(D3DRS_CULLMODE)
    ignored, state.alpha_test = device:GetRenderState(D3DRS_ALPHATESTENABLE)
    ignored, state.alpha_reference = device:GetRenderState(D3DRS_ALPHAREF)
    ignored, state.alpha_function = device:GetRenderState(D3DRS_ALPHAFUNC)
    ignored, state.vertex_shader = device:GetVertexShader()
    ignored, state.pixel_shader = device:GetPixelShader()
    ignored, state.texture0 = device:GetTexture(0)
    ignored, state.texture1 = device:GetTexture(1)

    local _, world = device:GetTransform(D3DTS_WORLD)
    local _, view = device:GetTransform(2)
    local _, projection = device:GetTransform(3)
    state.world = world ~= nil and copy_matrix(world) or nil
    state.view = view ~= nil and copy_matrix(view) or nil
    state.projection = projection ~= nil and copy_matrix(projection) or nil

    ignored, state.color_operation = device:GetTextureStageState(0, D3DTSS_COLOROP)
    ignored, state.color_argument1 = device:GetTextureStageState(0, D3DTSS_COLORARG1)
    ignored, state.color_argument2 = device:GetTextureStageState(0, D3DTSS_COLORARG2)
    ignored, state.alpha_operation = device:GetTextureStageState(0, D3DTSS_ALPHAOP)
    ignored, state.alpha_argument1 = device:GetTextureStageState(0, D3DTSS_ALPHAARG1)
    ignored, state.alpha_argument2 = device:GetTextureStageState(0, D3DTSS_ALPHAARG2)
    ignored, state.mag_filter = device:GetTextureStageState(0, D3DTSS_MAGFILTER)
    ignored, state.min_filter = device:GetTextureStageState(0, D3DTSS_MINFILTER)
    ignored, state.address_u = device:GetTextureStageState(0, D3DTSS_ADDRESSU)
    ignored, state.address_v = device:GetTextureStageState(0, D3DTSS_ADDRESSV)
    ignored, state.stage1_color = device:GetTextureStageState(1, D3DTSS_COLOROP)
    ignored, state.stage1_alpha = device:GetTextureStageState(1, D3DTSS_ALPHAOP)
    return state
end

local function restore_state(device, state)
    if state.world ~= nil then
        device:SetTransform(D3DTS_WORLD, table_to_matrix(state.world, restore_world))
    end
    if state.view ~= nil then
        device:SetTransform(2, table_to_matrix(state.view, restore_view))
    end
    if state.projection ~= nil then
        device:SetTransform(3, table_to_matrix(state.projection, restore_projection))
    end
    device:SetTexture(0, state.texture0)
    device:SetTexture(1, state.texture1)
    device:SetRenderState(D3DRS_LIGHTING, state.lighting)
    device:SetRenderState(D3DRS_ZENABLE, state.z_enable)
    device:SetRenderState(D3DRS_ZWRITEENABLE, state.z_write)
    device:SetRenderState(D3DRS_ZFUNC, state.z_function)
    device:SetRenderState(D3DRS_ZBIAS, state.z_bias)
    device:SetRenderState(D3DRS_ALPHABLENDENABLE, state.alpha_blend)
    device:SetRenderState(D3DRS_SRCBLEND, state.source_blend)
    device:SetRenderState(D3DRS_DESTBLEND, state.destination_blend)
    device:SetRenderState(D3DRS_CULLMODE, state.cull)
    device:SetRenderState(D3DRS_ALPHATESTENABLE, state.alpha_test)
    device:SetRenderState(D3DRS_ALPHAREF, state.alpha_reference)
    device:SetRenderState(D3DRS_ALPHAFUNC, state.alpha_function)
    device:SetVertexShader(state.vertex_shader)
    if state.pixel_shader ~= nil then
        device:SetPixelShader(state.pixel_shader)
    end
    device:SetTextureStageState(0, D3DTSS_COLOROP, state.color_operation)
    device:SetTextureStageState(0, D3DTSS_COLORARG1, state.color_argument1)
    device:SetTextureStageState(0, D3DTSS_COLORARG2, state.color_argument2)
    device:SetTextureStageState(0, D3DTSS_ALPHAOP, state.alpha_operation)
    device:SetTextureStageState(0, D3DTSS_ALPHAARG1, state.alpha_argument1)
    device:SetTextureStageState(0, D3DTSS_ALPHAARG2, state.alpha_argument2)
    device:SetTextureStageState(0, D3DTSS_MAGFILTER, state.mag_filter)
    device:SetTextureStageState(0, D3DTSS_MINFILTER, state.min_filter)
    device:SetTextureStageState(0, D3DTSS_ADDRESSU, state.address_u)
    device:SetTextureStageState(0, D3DTSS_ADDRESSV, state.address_v)
    device:SetTextureStageState(1, D3DTSS_COLOROP, state.stage1_color)
    device:SetTextureStageState(1, D3DTSS_ALPHAOP, state.stage1_alpha)
end

local function configure_depth_pass(device, viewport)
    local left = tonumber(viewport.X) or 0
    local top = tonumber(viewport.Y) or 0
    local width = tonumber(viewport.Width) or 0
    local height = tonumber(viewport.Height) or 0

    ffi.fill(ortho_matrix, ffi.sizeof('D3DMATRIX'), 0)
    ortho_matrix._11 = 2 / width
    ortho_matrix._22 = -2 / height
    ortho_matrix._33 = 1
    ortho_matrix._44 = 1
    ortho_matrix._41 = -1 - 2 * left / width
    ortho_matrix._42 = 1 + 2 * top / height

    device:SetTransform(D3DTS_WORLD, identity_matrix)
    device:SetTransform(2, identity_matrix)
    device:SetTransform(3, ortho_matrix)
    device:SetPixelShader(0)
    device:SetTexture(1, nil)
    device:SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE)
    device:SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE)
    device:SetRenderState(D3DRS_LIGHTING, 0)
    device:SetRenderState(D3DRS_CULLMODE, 1)
    device:SetRenderState(D3DRS_ALPHABLENDENABLE, 1)
    device:SetRenderState(D3DRS_SRCBLEND, 5)
    device:SetRenderState(D3DRS_DESTBLEND, 6)
    device:SetRenderState(D3DRS_ZENABLE, 1)
    -- The scene depth is complete at d3d_endscene; read it without changing it.
    device:SetRenderState(D3DRS_ZWRITEENABLE, 0)
    device:SetRenderState(D3DRS_ZFUNC, D3DCMP_LESSEQUAL)
    device:SetRenderState(D3DRS_ZBIAS, 0)
end

function renderer.render(device, labels, viewport, font, config, now)
    if #labels == 0 then
        return true
    end

    local width = tonumber(viewport.Width) or 0
    local height = tonumber(viewport.Height) or 0
    if width <= 0 or height <= 0 then
        return true
    end

    local layouts, layout_error = prepare_layouts(labels, font, config, viewport)
    if layouts == nil then
        return false, layout_error
    end
    resolve_overlaps(layouts, config, viewport)
    local texture = get_font_texture(font)
    if texture == nil then
        return false, 'The selected font atlas is not ready for depth rendering.'
    end

    local state = capture_state(device)
    local draw_ok, draw_error = pcall(function()
        configure_depth_pass(device, viewport)
        draw_colored_pass(device, layouts, config, now)
        draw_text_pass(device, layouts, texture, config, now)
    end)
    local restore_ok, restore_error = pcall(restore_state, device, state)
    if not restore_ok then
        return false, 'Could not restore the game render state: ' .. tostring(restore_error)
    end
    if not draw_ok then
        return false, tostring(draw_error)
    end
    return true
end

return renderer
