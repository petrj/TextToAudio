Clear-Host
Set-Location $PSScriptRoot

Import-Module ./ElevenLabs -Force 

$config = Get-Content -Path ./config.json | ConvertFrom-Json

@"
SHE: Could you take out the trash? It's already full.`n
HE: Sure, I'll do it right now.
"@ | Save-TextListAsMP3 -Configuration $config -Language "english" -StartCountFrom 5 -ExportDirectory .  -TextToFileName 