# Read-only prerequisite checks. Dot-sourcing this file performs no actions.
function Get-DockerDesktopRoots {
    $roots = @()
    if ($env:LOCALAPPDATA) { $roots += (Join-Path $env:LOCALAPPDATA 'Programs\DockerDesktop') }
    if ($env:ProgramFiles) {
        $roots += (Join-Path $env:ProgramFiles 'Docker\Docker')
        $roots += (Join-Path $env:ProgramFiles 'DockerDesktop')
    }
    foreach ($key in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop', 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop')) {
        $entry = Get-ItemProperty -LiteralPath $key -Name InstallLocation -ErrorAction SilentlyContinue
        if ($entry -and $entry.InstallLocation) { $roots += $entry.InstallLocation }
    }
    return @($roots | Select-Object -Unique)
}
function Get-PathDocker {
    $command = Get-Command docker.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    return $null
}
function Resolve-DockerExecutable {
    $onPath = Get-PathDocker
    if ($onPath) { return $onPath }
    # Read fresh registry environment; never persistently edit PATH.
    foreach ($scope in @('User', 'Machine')) {
        $fresh = [Environment]::GetEnvironmentVariable('Path', $scope)
        foreach ($directory in @($fresh -split ';')) {
            if (-not $directory) { continue }
            $candidate = Join-Path ([Environment]::ExpandEnvironmentVariables($directory.Trim('"'))) 'docker.exe'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }
    foreach ($root in @(Get-DockerDesktopRoots)) {
        foreach ($relative in @('resources\bin\docker.exe', 'bin\docker.exe', 'docker.exe')) {
            $candidate = Join-Path $root $relative
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }
    return $null
}
function Invoke-DockerProbe {
    param([string]$Executable, [string[]]$DockerArguments)
    $previous = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = (& $Executable @DockerArguments 2>&1 | Out-String)
        $code = $LASTEXITCODE
        return [pscustomobject]@{ ExitCode = $code; Output = $output }
    } catch { return [pscustomobject]@{ ExitCode = 1; Output = '' } }
    finally { $ErrorActionPreference = $previous }
}
function Get-DockerPreflight {
    $exe = Resolve-DockerExecutable
    if (-not $exe) { return [pscustomobject]@{ Status = 'cli-missing'; Executable = $null } }
    $compose = Invoke-DockerProbe -Executable $exe -DockerArguments @('compose', 'version')
    if ($compose.ExitCode -ne 0) { return [pscustomobject]@{ Status = 'compose-missing'; Executable = $exe } }
    $engine = Invoke-DockerProbe -Executable $exe -DockerArguments @('info', '--format', '{{.OSType}}')
    if ($engine.ExitCode -ne 0) { return [pscustomobject]@{ Status = 'engine-unavailable'; Executable = $exe } }
    $system = "$($engine.Output)".Trim().ToLowerInvariant()
    if ($system -eq 'windows') { return [pscustomobject]@{ Status = 'windows-containers'; Executable = $exe } }
    if ($system -ne 'linux') { return [pscustomobject]@{ Status = 'engine-unknown'; Executable = $exe } }
    return [pscustomobject]@{ Status = 'ready'; Executable = $exe }
}
function Write-DockerPreflight {
    param($Result)
    switch ($Result.Status) {
        'ready' { Write-Host '[READY] Docker Linux engine 與 Compose 已就緒。' -ForegroundColor Green }
        'cli-missing' {
            Write-Host '[DOCKER_CLI_MISSING] Windows 找不到 Docker 指令；目前尚未安裝龍蝦。' -ForegroundColor Yellow
            Write-Host '沒有 Docker Desktop：先雙擊 0-INSTALL-DOCKER-DESKTOP.bat，完成後開啟 Docker Desktop。'
            Write-Host '只有 WSL 裡有 Docker：請在該 WSL 的解壓資料夾內執行 bash linux/docker-install.sh。'
            Write-Host '已裝 Desktop 但仍找不到：先修復安裝或確認其安裝位置，不要反覆重裝龍蝦。'
        }
        'compose-missing' { Write-Host '[COMPOSE_MISSING] 已找到 Docker，但缺少 Compose；請檢查／更新自己的 Docker Desktop，不是重裝龍蝦。' -ForegroundColor Yellow }
        'engine-unavailable' { Write-Host '[ENGINE_UNAVAILABLE] 已找到 Docker 指令，但引擎無法連線；請開啟 Docker Desktop 並等它啟動完成，再執行 DOCKER-CHECK.bat。' -ForegroundColor Yellow }
        'windows-containers' { Write-Host '[LINUX_ENGINE_REQUIRED] Docker 正在使用 Windows containers；本包需要 Linux containers。請從 Docker Desktop 切換後再檢查。' -ForegroundColor Yellow }
        default { Write-Host '[ENGINE_UNKNOWN] 無法確認 Linux engine；停止安裝，不修改現有容器。' -ForegroundColor Yellow }
    }
}
function Get-DockerDesktopDownload {
    param([string]$Architecture)
    switch -Regex ($Architecture) {
        '^(AMD64|X64)$' { $arch = 'amd64'; break }
        '^ARM64$' { $arch = 'arm64'; break }
        default { throw 'Unsupported Windows architecture. Use the official Docker installation page.' }
    }
    return [pscustomobject]@{ Architecture = $arch; Url = ('https://desktop.docker.com/win/main/' + $arch + '/Docker%20Desktop%20Installer.exe') }
}
function Assert-TrustedDockerInstaller {
    param([string]$Path)
    $signature = Get-AuthenticodeSignature -LiteralPath $Path
    if ("$($signature.Status)" -ne 'Valid' -or -not $signature.SignerCertificate -or "$($signature.SignerCertificate.Subject)" -notmatch '(?i)(?:^|,\s*)(?:CN|O)="?Docker Inc\.?"?(?:,|$)') {
        throw 'Docker installer signature/publisher could not be verified. It will NOT be executed. Use the official download page to investigate.'
    }
}
