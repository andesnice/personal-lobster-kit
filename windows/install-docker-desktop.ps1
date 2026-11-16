$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'docker-preflight.ps1')
try {
    $existing = Resolve-DockerExecutable
    if ($existing) {
        Write-Host '已找到 Windows Docker 指令，不重複安裝。請開啟 Docker Desktop，再執行 DOCKER-CHECK.bat。'
        exit 0
    }
    $architecture = $env:PROCESSOR_ARCHITEW6432
    if (-not $architecture) { $architecture = $env:PROCESSOR_ARCHITECTURE }
    $download = Get-DockerDesktopDownload -Architecture $architecture
    $folder = Join-Path ([IO.Path]::GetTempPath()) ('personal-lobster-docker-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $folder | Out-Null
    $installer = Join-Path $folder 'DockerDesktopInstaller.exe'
    Write-Host '這是 Docker Desktop 官方線上安裝入口，不是離線安裝檔。'
    Write-Host '正在下載官方安裝程式；不更改 WSL、BIOS 或防火牆，也不代替你接受授權條款。'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri $download.Url -OutFile $installer
    Assert-TrustedDockerInstaller -Path $installer
    Write-Host '簽章與發行者驗證通過，即將開啟官方安裝介面。請依畫面完成必要權限／系統提示。'
    $process = Start-Process -FilePath $installer -Wait -PassThru
    if ($process.ExitCode -notin @(0, 3010)) { throw ('Docker installer ended with exit code ' + $process.ExitCode + '. Complete its displayed requirements before retrying.') }
    Write-Host '請依安裝器提示重新開機（若有），再從開始選單開啟 Docker Desktop，完成首次設定並等引擎啟動。'
    Write-Host '接著執行 DOCKER-CHECK.bat；顯示 READY 後才執行 DOCKER-INSTALL.bat 安裝龍蝦。'
    Write-Host ('官方安裝檔保留於：' + $installer + '；不需要時可自行刪除這個下載資料夾。')
} catch {
    Write-Host ('STOP: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host '官方安裝說明：https://docs.docker.com/desktop/setup/install/windows-install/'
    exit 1
}
