# Link/unlink base dotfiles and PowerShell profile (Windows).

function Unlink-Dotfiles {
    Write-Info "Removing dotfile links..."
    Remove-Link "$env:USERPROFILE\.gitconfig"
    Remove-Link "$env:USERPROFILE\.gitignore_global"
    Remove-Link "$env:USERPROFILE\.config\starship.toml"

    # PowerShell profile (copied, not symlinked)
    if (Test-Path $PROFILE) {
        Remove-Item $PROFILE -Force
        Write-Host "  [REMOVED] $PROFILE"
    }

    # Windows Terminal
    @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    ) | ForEach-Object {
        if (Test-Path $_) { Remove-Link $_ }
    }
}

function Link-Dotfiles {
    param([string]$DotfilesDir)

    Write-Info "Linking base dotfiles..."
    Ensure-Linked "$DotfilesDir\.gitconfig"        "$env:USERPROFILE\.gitconfig"
    Ensure-Linked "$DotfilesDir\.gitignore_global" "$env:USERPROFILE\.gitignore_global"

    # PowerShell profile — copy instead of symlink (OneDrive breaks symlinks in Documents)
    Write-Info "Copying PowerShell profile..."
    $profileSource = "$DotfilesDir\shell\powershell\Microsoft.PowerShell_profile.ps1"
    if (Test-Path $profileSource) {
        $profileDir = Split-Path -Parent $PROFILE
        try {
            New-Item -ItemType Directory -Path $profileDir -Force -ErrorAction Stop | Out-Null
            Copy-Item $profileSource $PROFILE -Force -ErrorAction Stop
            # Copy Oh My Posh theme alongside profile
            $themeSource = "$DotfilesDir\shell\powershell\pure.omp.json"
            if (Test-Path $themeSource) {
                Copy-Item $themeSource "$profileDir\pure.omp.json" -Force -ErrorAction Stop
            }
            Write-Host "  [COPY] $profileSource -> $PROFILE"
        }
        catch {
            Write-Warning "Could not copy PowerShell profile to $PROFILE"
            Write-Warning $_.Exception.Message
            Write-Host ""
            Write-Host "  This is likely caused by Controlled Folder Access (CFA) blocking writes" -ForegroundColor Yellow
            Write-Host "  to OneDrive-protected folders. To fix:" -ForegroundColor Yellow
            Write-Host "    1. Open Windows Security > Virus & threat protection" -ForegroundColor Cyan
            Write-Host "    2. Ransomware protection > Allow an app through Controlled folder access" -ForegroundColor Cyan
            Write-Host "    3. Add: $((Get-Process -Id $PID).Path)" -ForegroundColor Cyan
            Write-Host "    4. Re-run this setup script" -ForegroundColor Cyan
            Write-Host ""
        }
    }

    Write-Info "Linking config directories..."
    Ensure-Linked "$DotfilesDir\.config\starship.toml" "$env:USERPROFILE\.config\starship.toml"

    # Windows Terminal
    @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"
    ) | ForEach-Object {
        if (Test-Path $_) {
            Ensure-Linked "$DotfilesDir\.config\windows-terminal\settings.json" "$_\settings.json"
        }
    }
}
