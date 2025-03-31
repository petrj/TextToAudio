Clear-Host
Set-Location $PSScriptRoot

if (Get-Module -Name ElevenLabs)
{
    Remove-Module -Name ElevenLabs
}
Import-Module ./ElevenLabs 


$config = Get-Content -Path ./config.json | ConvertFrom-Json

#$config | Get-Voices
#$config | Get-Voices | Where-Object { $_.supported_languages -contains "cs" }

#Get-Content -Path ./input.txt | Save-TextListAsMP3 -Configuration $config -ExportDirectory .  -TextToFileName

@"
VYPRAVĚČ: Mezitím se žhaví neuronová síť`n
ON: Ahoj, já jsem překladatel z textu do mluvené řeči`n
ONA: Jé, to je báječné, vše funguje
"@ | Save-TextListAsMP3 -Configuration $config -ExportDirectory .  -TextToFileName 