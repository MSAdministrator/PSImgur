Function Get-ImgurAuthToken{
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
                [string]$ClientSecret,

    [parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage='Please enter your Imgur Client Secret')]
                [ValidateNotNullOrEmpty()]
                [string]$AuthCode)
#params 

    $RegKey = "HKLM:\SOFTWARE\Imgur\API"
    $tokenURL = 'https://api.imgur.com/oauth2/token'
    #The money shot, this will have our token that we'll use
    try { 
        $result = Invoke-RestMethod $tokenURL -Method Post `
			-Body @{client_id=$ClientID; 
				client_secret=$ClientSecret; 
				grant_type="authorization_code"; 
				code=$AuthCode} `
			-ContentType "application/x-www-form-urlencoded" -ErrorAction STOP
        
        Write-Debug 'Invoke-RestMethod completed successfully'
     }
    catch{
        Write-Warning 'Invoke-RestMethod failed:`n`t'
    }
    
    Write-Debug 'Attempting to add result to local Registry'

    if ($result.access_token){
        Write-Debug "Adding AccessToken: $($result.access_token)"  
        Set-ItemProperty -Path $RegKey -Name 'AccessToken' -Value $($result.access_token) -Type String

        Write-Debug "Adding RefreshToken: $($result.refresh_token)" 
        Set-ItemProperty -Path $RegKey -Name 'RefreshToken' -Value $($result.refresh_token) -Type String

        Write-Debug "Adding TokenExpiration: (Get-date -Format "yyyy-MM-dd HH:mm:ss")" 
        Set-ItemProperty -Path $RegKey -Name "TokenExpiration" -Value (Get-date -Format "yyyy-MM-dd HH:mm:ss") -Force

        Write-Debug "Adding AccountUsername: $($result.account_username)"
        Set-ItemProperty -Path $RegKey -Name 'AccountUsername' -Value $($result.account_username) -Type String

        $global:imgur_accessToken = $result.access_token
        $global:imgur_refreshToken = $result.refresh_token
        $global:imgur_username = $result.account_username
        
        }
    
}

<#refresh tokens, not implemented yet

$result = Invoke-RestMethod $tokenURL -Method Post `
			-Body @{
                refresh_token = $refresh;
                client_id=$clientId; 
				client_secret=$clientSecret; 
				grant_type="authorization_code"; 
            } -ContentType "application/x-www-form-urlencoded" -ErrorAction STOP

            #>