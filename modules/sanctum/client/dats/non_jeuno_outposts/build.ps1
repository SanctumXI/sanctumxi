param(
    [string]$FfxiRoot = 'C:\Sanctum XI\SquareEnix\FINAL FANTASY XI',
    [string]$Output = (Join-Path $PSScriptRoot 'package')
)

python (Join-Path $PSScriptRoot 'build_non_jeuno_outposts.py') `
    --ffxi-root $FfxiRoot `
    --output $Output

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
