function Assert-LocalBundlePath {
    param([string]$Path, [bool]$WindowsHost = ($env:OS -eq 'Windows_NT'))
    if (-not $WindowsHost) { return }
    if ($Path -match '^[\\/]{2}') { throw 'Bundle is on a network share. Copy the COMPLETE folder to a local disk such as D:\OpenClaw, then reopen the launcher. Existing Docker volumes must not be deleted.' }
    if ($Path -notmatch '^([A-Za-z]):[\\/]') { throw 'Cannot verify a local Windows bundle path. Extract the complete ZIP to a local C: or D: folder.' }
    $driveName = $Matches[1]
    try { $drive = Get-PSDrive -Name $driveName -PSProvider FileSystem -ErrorAction Stop } catch { throw 'Could not verify the bundle drive. No Compose action was attempted.' }
    if ($drive.DisplayRoot -match '^[\\/]{2}' -or $drive.Root -match '^[\\/]{2}') { throw 'Bundle drive maps to a network share. Copy the COMPLETE folder to a physical local disk; changing a drive letter alone is not enough.' }
}
