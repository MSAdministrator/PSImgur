<#
.Synopsis
    Use this cmdlet to connect to a Imgur account for management via PowerShell
.DESCRIPTION
    With one cmdlet, you can connect to your Imgur account via the REST API.  After using this cmdlet, you can use any of the other *Imgur cmdlets to do things like upload an image or an album, etc (to come later)
.EXAMPLE
    Connect-ImgurAccount -ClientID [String] -ClientSecret [ClientSecret]

    Sign up at http://api.imgur.com/oauth2/addclient and make a new application ID, which is needed to query to Imgur API.  While you're there, specify a redirect URL, which should be the URL of any random site.  You'll receive a ClientID, ClientSecret which you must provide to this cmdlet.

    Upon running, a Internet Explorer com object window will be displayed, prompting you to login and authorize your Application ID (PowerShell, effectively) to interact with your Imgur account.  Click the appropriate boxes, and then close the browser window when you see the window get redirected.

    Behind the scenes, this cmdlet will retrieve an Access Token, convert it to an Authorization Token, and store it safely within your profile.  Other PSImgur API calls require this Authorization token, and it will be automatically provided when needed.
.EXAMPLE
    Connect-ImgurAccount -Force

    If you need to renew your API key (roughly once a month), then rerun the cmdlet with -Force
#>
Function Connect-ImgurAccount {
[CmdletBinding()]
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
                [string]$clientSecret
    )

    $RegKey = "HKLM:\SOFTWARE\Imgur\API"
    Write-Verbose "regkey; " $RegKey
    if(Test-Path -Path $RegKey){
        Write-Debug "Attempting to retrieve OAuth Info from Registry:`r`n"

        $ClientID = (Get-ItemProperty -Path $RegKey -Name 'ClientID').ClientID
        $ClientSecret = (Get-ItemProperty -Path $RegKey -Name 'ClientSecret').ClientSecret
        $AuthCode = (Get-ItemProperty -Path $RegKey -Name 'AuthCode').AuthCode
        $AccessToken = (Get-ItemProperty -Path $RegKey -Name 'AccessToken').AccessToken
    }
    else{
        #if path does not exist, then get AuthCode
        $AuthCode = Get-ImgurAuthCode -ClientID $ClientID -ResponseType code

        if ($AuthCode){

            Get-ImgurAuthToken -ClientID $ClientID -clientSecret $clientSecret -authCode $AuthCode    
    
        }
    }     
}