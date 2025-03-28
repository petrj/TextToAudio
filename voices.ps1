Clear-Host
Set-Location $PSScriptRoot

if (Get-Module -Name ElevenLabs)
{
    Remove-Module -Name ElevenLabs
}
Import-Module ./ElevenLabs 


$apiKey = "" 

Get-Voices -ApiKey $apiKey 