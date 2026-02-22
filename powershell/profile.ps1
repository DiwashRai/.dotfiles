
Set-PSReadLineOption -PredictionSource None

# aliases
## Remove default aliases
Remove-Item Alias:cat -ErrorAction SilentlyContinue

## Custom  aliases
function profile {
    nvim $PROFILE
    . $PROFILE
}

### shell utilities
Set-Alias list Get-LocationBookmark
Set-Alias remove Remove-LocationBookmark
Set-Alias cat bat

$env:LL_ARGS = "-l --color always --group-directories-first --no-filesize --icons always --no-permissions"
function ll {
    eza @($env:LL_ARGS.Split(' ')) @args
}

function yaz {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}
Set-Alias y yaz

## git aliases
function gs { git status }

# PSFzf
Set-PsFzfOption `
    -PSReadlineChordProvider 'Ctrl+t'`
    -PSReadlineChordReverseHistory 'Ctrl+r'`
    -GitKeyBindings `
    -EndableFd `
    -TabExpansion

$env:FZF_DEFAULT_COMMAND = "fd.exe -c always -H -F -E .git -E .vs -E x64 -E node_modules --full-path"
$env:FZF_DEFAULT_OPTS = @"
--height 40%
--layout reverse
--border
--preview 'bat --style=numbers --color=always --line-range :500 {}'
--preview-window right:60%:wrap
--ansi
"@ -replace "`r?`n", ' '

$env:FZF_CTRL_R_OPTS = @"
--preview ''
--preview-window hidden
"@ -replace "`r?`n", ' '

$env:FZF_ALT_C_COMMAND = "$env:FZF_DEFAULT_COMMAND --type d"
$env:FZF_ALT_C_OPTS = @"
--preview "eza $env:LL_ARGS -- {}"
"@ -replace "`r?`n", ' '

# prompt
$esc = [char]27
$global:BranchColor = "$esc[34m"
#$global:BranchColor = $PSStyle.Foreground.FromRgb(156,207,216)
$global:ColorReset  = "$esc[0m"

function prompt {
    $path = $executionContext.SessionState.Path.CurrentLocation
    $currDir = $path.ProviderPath
    $headPath = $null

    foreach ($depth in 0..3) {
        $headTry = Join-Path $currDir ".git\HEAD"
        if ([IO.File]::Exists($headTry)) { $headPath = $headTry; break }

        $parentDir = [IO.Directory]::GetParent($currDir)
        if (-not $parentDir) { break }
        $currDir = $parentDir.FullName
    }

    if ($headPath) {
        $headLine = [IO.File]::ReadLines($headPath) | Select-Object -First 1
        $branch = $headLine.Substring(16)   # assumes "ref: refs/heads/"
        "PS $path [$($global:BranchColor)$branch$($global:ColorReset)]> "
    }
    else {
        "PS $path> "
    }
}

# Just handler
function Invoke-JustFzfFromTrigger([switch]$force) {
    $line = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if (-not $Force -and $line -notmatch '^\s*just\s+\*\*\s*$') { return $false }

    $raw = try { just --summary 2>$null } catch { '' }
    $items = $raw -split '\s+' | Where-Object { $_ }

    $pick = $items |
        Invoke-Fzf -Preview 'just --show {1}'

    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    if (-not $pick) { return $true }

    $new = "just $pick"
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $new)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($new.Length)
    return $true
}

# our own heavy hook for tab. maybe fix later
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    if (Invoke-JustFzfFromTrigger) { return }
    [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
}

