
function Get-Voices 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [string]$LanguageFilter = $null,

        [string]$ApiEndpoint = "https://api.elevenlabs.io/v1"  # Default API endpoint
    )

    # Construct API URL
    $url = "$ApiEndpoint/voices"

    # Headers
    $headers = @{
        "xi-api-key" = $ApiKey
        "Content-Type" = "application/json"
    }

    # Fetch available voices
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        $voices = $response.voices

        if (-not ([string]::IsNullOrEmpty($LanguageFilter)))
        {
            $voices = $voices | Where-Object { $_.supported_languages -contains $LanguageFilte }

        }

        if ($voices.Count -eq 0) 
        {
            Write-Host "No voices found."
        } else {
            Write-Host "Available voices:"
            $voices | ForEach-Object { Write-Host "$($_.name) (ID: $($_.voice_id))" }
        }
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
        Write-Host "Speech synthesis complete. Output saved as $OutputFile (voice id $VoiceId)"
    } catch 
    {
        Write-Host "Error: $_"
    }
}

Export-ModuleMember -Function Get-Voices, Save-TextAsMP3 
