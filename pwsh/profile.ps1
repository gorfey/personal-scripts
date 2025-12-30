#region General options
Set-PSReadlineOption -EditMode Windows
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord
Set-PSReadlineKeyHandler -Key PageUp -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key PageDown -Function HistorySearchForward
#endregion
#region General aliases/functions
$homeDir = if ($HOME) { $HOME } else { [System.Environment]::GetFolderPath('UserProfile') }
$localBin = Join-Path $homeDir '.local/bin'
if (Test-Path $localBin) {
    $sep = [System.IO.Path]::PathSeparator
    $env:PATH = "$localBin$sep$env:PATH"
}
Set-Alias -Name:eps -Value:"Enter-PsSession"
function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo | Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception | Format-List * -Force
   }
}
function modulize {
    Get-ChildItem -Recurse *.psm1 | Import-Module -Force
}
#endregion
#region Prompt
function Test-IsPSSession {
    return $null -ne $PSSenderInfo
}

function Test-IsSshEnvironment {
    return (
        -not [string]::IsNullOrEmpty($env:SSH_CONNECTION) -or
        -not [string]::IsNullOrEmpty($env:SSH_CLIENT) -or
        -not [string]::IsNullOrEmpty($env:SSH_TTY)
    )
}

function Test-IsSshdAncestor {
    try {
        $currentPid = $PID
        while ($currentPid -and $currentPid -ne 0) {
            $proc = Get-Process -Id $currentPid -ErrorAction SilentlyContinue
            if (-not $proc) { break }
            if ($proc.ProcessName -eq 'sshd') { return $true }
            # Defensive check: If Parent is null or Id is 0, stop loop
            if (-not $proc.Parent -or $proc.Parent.Id -eq 0) { break }
            $currentPid = $proc.Parent.Id
        }
    }
    catch {
        # Suppress errors, return false if any exception occurs
    }
    return $false
}

if ( (Test-IsPSSession) -or (Test-IsSshEnvironment) -or (Test-IsSshdAncestor) ) {
    $env:IS_REMOTE = $true
}

function Prompt {
    $user = [System.Environment]::UserName
    $path = $executionContext.SessionState.Path.CurrentLocation.Path
    $promptSymbol = '>' * ($nestedPromptLevel + 1)

    if ($env:IS_REMOTE) {
        $hostName = [System.Environment]::MachineName
        $promptString = "${user}@${hostName} ${path}${promptSymbol} "
    }
    else {
        $promptString = "${user} ${path}${promptSymbol} "
    }

    return $promptString
}
#endregion
#region App options and aliases
$configRoot = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "config"
if (Get-Command "batcat" -ErrorAction Ignore) {
    Set-Alias -Name:bat -Value:"batcat"
}
$env:BAT_THEME = 'Visual Studio Dark+'

if (Get-Command "lsd" -ErrorAction Ignore) {
    function lla { lsd -lah $args }
}

if (Get-Command "less" -ErrorAction Ignore) {
    $env:LESS = '--mouse'
}

if (Get-Command "rg" -ErrorAction Ignore) {
    $rgConfigFile = Join-Path -Path $configRoot -ChildPath ".ripgreprc"
    $env:RIPGREP_CONFIG_PATH = (Get-Item -Force $rgConfigFile).FullName
}

if (Get-Command "micro" -ErrorAction Ignore) {
    $env:EDITOR = 'micro'
}
elseif (Get-Command "nano" -ErrorAction Ignore) {
    $env:EDITOR = 'nano'
}
#endregion
#region Extensibility
$modulesDir = "$PSScriptRoot/modules"
$extensionsDir = "$PSScriptRoot/extensions"
if (Test-Path $modulesDir -Type Container) {
    $modules = Get-ChildItem -Path $modulesDir -File
    foreach ($module in $modules) {
        Import-Module -Force ($module.FullName)
    }
}
if (Test-Path $extensionsDir -Type Container) {
    $extensions = Get-ChildItem -Path $extensionsDir -File
    foreach ($extension in $extensions) {
        . ($extension.FullName)
    }
}
#endregion
#region Late commands
if (Get-Command "zoxide" -ErrorAction Ignore) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) } )
    Set-Alias -Name:cd -Value:"z" -Option AllScope # Could also pass a parameter to zoxide init; I like both being around though.
}

if (Get-Command "oh-my-posh" -ErrorAction Ignore) {
    $ompConfigFile = Join-Path -Path $configRoot -ChildPath "oh-my-posh.yaml"
    Invoke-Expression (oh-my-posh init pwsh --config $ompConfigFile)
}
#endregion
