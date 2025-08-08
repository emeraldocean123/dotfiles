# --- Bootstrap: Force vendored PSReadLine 2.4.1 before anything else ---
try {
    $DotfilesDir  = Join-Path $HOME "Documents\dotfiles"
    $VendoredPsd1 = Join-Path $DotfilesDir "modules\PSReadLine\2.4.1\PSReadLine.psd1"

    if (Test-Path -LiteralPath $VendoredPsd1) {
        $loaded = Get-Module PSReadLine
        if ($loaded) { Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue }

        Import-Module -Name $VendoredPsd1 -Force -ErrorAction Stop
        Write-Host "PSReadLine loaded (vendored 2.4.1)" -ForegroundColor Green
    }
}
catch {
    Write-Warning ("Bootstrap could not load vendored PSReadLine: {0}" -f $_.Exception.Message)
}
