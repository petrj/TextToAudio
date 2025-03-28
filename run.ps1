Clear-Host
Set-Location $PSScriptRoot

if (Get-Module -Name ElevenLabs)
{
    Remove-Module -Name ElevenLabs
}
Import-Module ./ElevenLabs 


$apiKey = "" 

#Get-Voices -ApiKey $apiKey -LanguageFilter "cs"

$inputFileName = "input.txt"
$voices = @{
    "SHE" = "XrExE9yKIg1WjnnlVkGX"  # Matilda
    "HE" = "TX3LPaxmHKxFdv7VOQHJ" # Liam
}
$textToFileName = $true

$input = Get-Content -Path $inputFileName

function Remove-NonAsciiCharacters 
{
    param (
        [string]$txt
    )

    $txt = $txt.Replace("ě", "e")
    $txt = $txt.Replace("ř", "r")
    $txt = $txt.Replace("í", "i")
    $txt = $txt.Replace("š", "s")
    $txt = $txt.Replace("č", "c")
    $txt = $txt.Replace("ž", "z")
    $txt = $txt.Replace("ý", "y")
    $txt = $txt.Replace("á", "a")
    $txt = $txt.Replace("é", "e")
    $txt = $txt.Replace("ú", "u")
    $txt = $txt.Replace("ů", "u")

    return ($txt -creplace '[^A-Za-z0-9]', '_')
}

$num = 1
foreach ($line in $input)
{
    $voiceAndText = $line.Split(":",2) 
    if ($voiceAndText.Count -eq 2)
    {
        $voice = $voiceAndText[0]
        $text = $voiceAndText[1]

        if (-not ($voices.ContainsKey($voice)))
        {
            Write-Host "Unknown voice: $voice"
            continue
        }

        $fileName = $num.ToString().PadLeft(3 , "0") 

        if ($textToFileName)
        {
            $txt = $text

            $txt = $txt.Replace("ě", "e")
            $txt = $txt.Replace("ř", "r")     

            $fileName += "_"
            $fileName += Remove-NonAsciiCharacters  -txt $text
        }

        $fileName += ".mp3"

        Save-TextAsMP3 -Text $text -ApiKey $apiKey -VoiceId $voices[$voice] -OutputFile $fileName

        $num++
    }
}
