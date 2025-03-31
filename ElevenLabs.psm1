function Remove-NonASCII 
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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



function Get-Voices 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Configuration,

        [string]$ApiEndpoint = "https://api.elevenlabs.io/v1"  # Default API endpoint
    )

    # Construct API URL
    $url = "$ApiEndpoint/voices"

    # Headers
    $headers = @{
        "xi-api-key" = $Configuration.apiKey
        "Content-Type" = "application/json"
    }

    # Fetch available voices
    try 
    {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        return $response.voices | Select-Object -Property name,voice_id
        
    } catch 
    {
        Write-Host "Error: $_"
    }
}


function Save-TextAsMP3
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [string]$ApiEndpoint = "https://api.elevenlabs.io/v1",  # Default API endpoint

        [Parameter(Mandatory = $true)]
        [string]$VoiceId,

        [string]$Language = "czech",
        [string]$OutputFile = "output.mp3"
    )

    # Construct the API URL
    $url = "$ApiEndpoint/text-to-speech/$VoiceId"

    # JSON Payload
    $body = @{
        text = $Text
        model_id = "eleven_multilingual_v2"
        language = $Language
    } | ConvertTo-Json -Depth 10

    # Headers
    $headers = @{
        "xi-api-key" = $ApiKey
        "Content-Type" = "application/json"
    }

    # Send API request
    try 
    {
        Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -OutFile $OutputFile 
        $OutputFile
    } catch 
    {
        Write-Host "Error: $_"
    }
}


function Save-TextListAsMP3
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InputText,

        [Parameter(Mandatory = $true)]
        $Configuration,

        [Parameter(Mandatory = $false)]
        [string]$ApiEndpoint = "https://api.elevenlabs.io/v1",  # Default API endpoint

        [Parameter(Mandatory = $false)]
        [int]$StartCountFrom=1,

        [Parameter(Mandatory = $false)]
        [string]$ExportDirectory = $null,        
     
        [Parameter(Mandatory = $false)]
        [string]$Language = "czech",
     
        [Switch]
        $TextToFileName,

        [Switch]
        $Detailed
    )
    Begin
    {
        $num = $StartCountFrom
    }
    Process 
    {
        if ([String]::IsNullOrWhiteSpace($ExportDirectory))
        {
            $ExportDirectory = [System.IO.Path]::GetTempPath()
        }

        foreach ($line in $InputText.Split("`n"))
        {
            if (([String]::IsNullOrWhiteSpace($line)) -or ($line.Trim().StartsWith("#")))
            {
                continue
            }    
        
            $voiceAndText = $line.Split(":",2) 
            if ($voiceAndText.Count -eq 2)
            {
                $voice = $voiceAndText[0]
                $text = $voiceAndText[1]

                $configVoice = $Configuration.voices | Where-Object { $_.name -eq $voice }

                if ($configVoice -eq $null)
                {
                    Write-Host ("Voice " + $voice + " not found in Configuration")
                    continue;
                }

                if ($Detailed)
                {
                    Write-Host ("Using voice " + $configVoice.name + "(" + $configVoice.id + ")")
                }

                $fileName = Join-Path -Path $ExportDirectory -ChildPath $num.ToString().PadLeft(3 , "0") 
        
                $fileName += "_"
                $fileName += $voice.PadRight(10,"_") | Remove-NonASCII
        
                if ($TextToFileName)
                {
                 
                    $fileName += "_"
                    $fileName += $text | Remove-NonASCII
                }
        
                $fileName += ".mp3"
        
                if ($Detailed)
                {
                    Write-Host ("Saving to $fileName")
                }
                                
                Save-TextAsMP3 -Text $text -ApiKey $Configuration.apiKey -VoiceId $configVoice.id -OutputFile $fileName -Language $Language
        
                $num++
            }
        }
         
    }
}

Export-ModuleMember -Function Remove-NonASCII, Get-Voices, Save-TextAsMP3, Save-TextListAsMP3 
