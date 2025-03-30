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
    "SHE" = "XrExE9yKIg1WjnnlVkGX"      # Matilda
    "HE" = "TX3LPaxmHKxFdv7VOQHJ"       # Liam
    "ONA" = "12CHcREbuPdJY02VY7zT"      # Hanka (beta)
    "ON" = "uYFJyGaibp4N2VwYQshk"       # Adam
    "VYPRAVĚČ" = "NHv5TpkohJlOhwlTCzJk" # Pawel
    "IRIS" = "12CHcREbuPdJY02VY7zT"      # Hanka (beta)
    "LEA" = "21m00Tcm4TlvDq8ikWAM"      # Rachel

}
$textToFileName = $true

$input = Get-Content -Path $inputFileName

function Remove-NonAsciiCharacters 
{
    param (
        [string]$txt
    )

    $txt = $txt.Replace("ě", "e").Replace("Ě", "E")
    $txt = $txt.Replace("ř", "r").Replace("Ř", "R")
    $txt = $txt.Replace("í", "i").Replace("Í", "I")
    $txt = $txt.Replace("š", "s").Replace("Š", "S")
    $txt = $txt.Replace("č", "c").Replace("Č", "C")
    $txt = $txt.Replace("ž", "z").Replace("Ž", "Z")
    $txt = $txt.Replace("ý", "y").Replace("Ý", "Y")
    $txt = $txt.Replace("á", "a").Replace("Á", "A")
    $txt = $txt.Replace("é", "e").Replace("É", "E")
    $txt = $txt.Replace("ú", "u").Replace("Ú", "U")
    $txt = $txt.Replace("ů", "u").Replace("Ů", "U")

    return ($txt -creplace '[^A-Za-z0-9]', '_')
}

$num = 1
foreach ($line in $input)
{
    if ([String]::IsNullOrWhiteSpace($line))
    {
        continue
    }

    if ($line.Trim().StartsWith("#"))
    {
        continue
    }    

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

        $fileName += "_"
        $fileName += Remove-NonAsciiCharacters -txt ($voice.PadRight(10,"_"))


        if ($textToFileName)
        {
            $txt = $text

            $txt = $txt.Replace("ě", "e")
            $txt = $txt.Replace("ř", "r")     

            $fileName += "_"
            $fileName += Remove-NonAsciiCharacters  -txt $text
        }

        $fileName += ".mp3"

        Write-Host ("Saving to $fileName")

        Save-TextAsMP3 -Text $text -ApiKey $apiKey -VoiceId $voices[$voice] -OutputFile $fileName

        $num++
    }
}
