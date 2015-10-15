#this function calls the authorize API, using the Show-oAuthWindow to show a, uh, window for the user to login to
Function Get-ImgurAuthCode{
param(
    [parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage='Please enter your Imgur Client ID')]
                [ValidateNotNullOrEmpty()]
                [string]$ClientID,
        
    [parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage='Please enter your Imgur Client Secret')]
                [ValidateNotNullOrEmpty()]
                [string]$ResponseType
)

    $url = "https://api.imgur.com/oauth2/authorize?client_id=$clientID&response_type=$ResponseType"

    $uri = Show-OAuthWindow -url $url

    #After this, there should be a variable called $uri, which has our code!!!!!!!!!!!
    #(?<=code=)(.*)(?=&)
    $regex = '(?<=code=)(.*)'
    try 
    {
        $authCode  = ($uri | Select-string -pattern $regex -ErrorAction STOP).Matches[0].Value
    }
    catch{
        write"didn't get a code, trying again"
        Show-OAuthWindow -url $url 
    }

    write-verbose "New Auth Code acquired: $authCode"

    $RegKey = "HKLM:\SOFTWARE\Imgur\API"
    if(-not (Test-Path -Path $RegKey)){
        New-Item $RegKey -Force
    }

    Write-output "Received an authCode, $authcode"
    
     #Write AuthCode to Registry.
    Set-ItemProperty -Path $RegKey -Name 'ClientID' -Value $authCode -Type String

    #returning authcode, even though it's in registry
    return $authCode
}
#Next, get an access token by presenting the code