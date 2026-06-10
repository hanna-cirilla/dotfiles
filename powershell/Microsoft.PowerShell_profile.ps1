oh-my-posh init pwsh --config '~/.mytheme.omp.json' | Invoke-Expression
Set-PSReadlineOption -PredictionSource HistoryAndPlugin
Set-PSReadlineOption -ShowTooltips:$false
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key 'Ctrl+d' -Function DeleteCharOrExit
Set-PSReadLineOption -Colors @{
    Command            = '#BD93F9'  # Purple   — cmdlets, functions
    Comment            = '#6272A4'  # Comment  — subtle blue-gray
    ContinuationPrompt = '#44475A'  # Selection
    Default            = '#F8F8F2'  # Foreground
    Emphasis           = '#FF92DF'  # Bright Magenta — search matches
    Error              = '#FF5555'  # Red
    Keyword            = '#FF79C6'  # Pink     — if/foreach/return
    Member             = '#8BE9FD'  # Cyan     — .Property
    Number             = '#FFB86C'  # Orange
    Operator           = '#F1FA8C'  # Yellow   — | > =
    Parameter          = '#8BE9FD'  # Cyan     — -Flag
    Selection          = "`e[38;2;40;42;54m`e[48;2;189;147;249m"  # fg=#282A36 bg=Purple
    String             = '#50FA7B'  # Green
    Type               = '#FF79C6'  # Pink     — [System.String]
    Variable           = '#FFB86C'  # Orange   — $var
}

Import-Module posh-git

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

# ── Terminal-Icons ────────────────────────────────────────────────────────────
# Nerd Font icons in Get-ChildItem output (Cascadia Code NF ✓)
Import-Module -Name Terminal-Icons

# ── PSFzf (fzf integration) ───────────────────────────────────────────────────
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider       'Ctrl+t'   # file picker
Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'   # history search
Set-PsFzfOption -TabExpansion                             # git ** <Tab>

$env:FZF_DEFAULT_OPTS    = '--height 50% --layout=reverse --border=rounded --prompt="  " --pointer="▶" --marker="✓"'
$env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!{.git,node_modules,bin,obj}"'
$env:FZF_CTRL_T_OPTS     = '--preview "bat --color=always --style=numbers --line-range=:100 {}"'

# ── Environment Variables ─────────────────────────────────────────────────────
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_NOLOGO               = '1'
$env:ASPNETCORE_ENVIRONMENT      = 'Development'
$env:NODE_ENV                    = 'development'
$env:NPM_CONFIG_FUND             = 'false'
$env:EDITOR                      = 'nvim'

# ── Git Aliases ───────────────────────────────────────────────────────────────
function gs   { git status @args }
function ga   { git add @args }
function gaa  { git add --all }
function gc   { git commit -m @args }
function gp   { git push @args }
function gpl  { git pull @args }
function gf   { git fetch @args }
function gl   {
    git log --oneline --graph --decorate --color=always `
        --format="%C(magenta)%h%C(reset) %C(blue)%ar%C(reset) %s %C(dim white)(%an)%C(reset)%C(auto)%d" `
        @args
}
function gco  { git checkout @args }
function gcb  { git checkout -b @args }
function gd   { git diff @args }
function gds  { git diff --staged @args }

# ── .NET / C# Aliases ─────────────────────────────────────────────────────────
function dnr   { dotnet run @args }
function dnb   { dotnet build @args }
function dnt   { dotnet test @args }
function dnw   { dotnet watch @args }
function dnwr  { dotnet watch run @args }
function dnpub { dotnet publish @args }
function dnrst { dotnet restore @args }

# Open first .sln in current dir with Visual Studio
function vs {
    $sln = Get-ChildItem -Filter '*.sln' | Select-Object -First 1
    if ($sln) { Start-Process $sln.FullName }
    else { Write-Warning "No .sln file found in current directory" }
}

# ── Node / npm Aliases ────────────────────────────────────────────────────────
function ni   { npm install @args }
function nid  { npm install --save-dev @args }
function nr   { npm run @args }
function nrd  { npm run dev }
function nrb  { npm run build }
function nrt  { npm run test }
function nlg  { npm list --global --depth=0 }

# ── Utility Functions ─────────────────────────────────────────────────────────
function which  { Get-Command @args | Select-Object -ExpandProperty Source }
function touch  {
    param([string]$Path)
    if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date }
    else { New-Item -ItemType File -Path $Path | Out-Null }
}
function ll     { Get-ChildItem -Force @args }
function reload { . $PROFILE }
function v.     { nvim . }

# Kill process listening on a given port
function Stop-ByPort {
    param([int]$Port)
    $procId = (netstat -ano | Select-String ":$Port\s" |
        ForEach-Object { ($_ -split '\s+')[-1] } | Select-Object -First 1)
    if ($procId) {
        Stop-Process -Id $procId -Force
        Write-Host "Killed PID $procId on :$Port" -ForegroundColor Green
    } else {
        Write-Warning "No process found on port $Port"
    }
}
Set-Alias -Name killport -Value Stop-ByPort

# Find TODO/FIXME/HACK/BUG comments in source tree
function todos {
    rg --type-add 'code:*.{cs,js,ts,tsx,jsx,ps1,json,md}' `
       --type code -n --color=always 'TODO|FIXME|HACK|BUG' .
}

function edit-profile { nvim $PROFILE }

# ── Dev Container ─────────────────────────────────────────────────────────────
function ucopilot {
    $baseImage = 'for.artifactory.siemens-healthineers.com/di_ct/uniform-installation/devcontainer'
    $container = docker ps --format '{{.Names}}\t{{.Image}}' |
        Where-Object { ($_ -split "`t")[1] -like "$baseImage*" } |
        Select-Object -First 1 |
        ForEach-Object { ($_ -split "`t")[0] }

    if (-not $container) {
        Write-Error "No running container found for image: $baseImage"
        return
    }

    Write-Host "→ Attaching Copilot session in container: $container" -ForegroundColor Cyan
    docker exec -it -u vscode -w /workspaces/UniformInstallation -e ADO_TOKEN=$env:COPILOT_CLI_AZURE_DEVOPS_SERVER_TOKEN $container copilot
}
