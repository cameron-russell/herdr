# installed by herdr
# managed by herdr; reinstalling or updating the integration overwrites this file.
# add custom hooks beside this file instead of editing it.
# HERDR_INTEGRATION_ID=auggie
# HERDR_INTEGRATION_VERSION=1

param([string]$Action = "")

if ($Action -ne "session") { exit 0 }
if ($env:HERDR_ENV -ne "1") { exit 0 }
if ([string]::IsNullOrWhiteSpace($env:HERDR_PANE_ID)) { exit 0 }

$inputText = [Console]::In.ReadToEnd()
try {
    $payload = if ([string]::IsNullOrWhiteSpace($inputText)) { $null } else { $inputText | ConvertFrom-Json }
} catch {
    $payload = $null
}

$sessionId = $null
if ($null -ne $payload) {
    if (-not [string]::IsNullOrWhiteSpace($payload.conversation_id)) {
        $sessionId = $payload.conversation_id
    } elseif (-not [string]::IsNullOrWhiteSpace($payload.conversationId)) {
        $sessionId = $payload.conversationId
    }
}
if ([string]::IsNullOrWhiteSpace($sessionId)) { $sessionId = $env:AUGMENT_CONVERSATION_ID }
if ([string]::IsNullOrWhiteSpace($sessionId)) { exit 0 }

$seq = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
try {
    & herdr pane report-agent-session $env:HERDR_PANE_ID --source herdr:auggie --agent auggie --agent-session-id $sessionId --seq $seq 2>$null | Out-Null
} catch {
}
