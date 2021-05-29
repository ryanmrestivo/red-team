Login-AzAccount
Set-AzContext -Subscription "YOUR SUBSCRIPTION HERE"

# Replace with your Workspace ID
$CustomerId = ""  

# Replace with your Primary Key
$SharedKey = ""

# Specify the name of the record type that you'll be creating for the custom Table
$LogType = "EnrichedO365Log"

# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = ""

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}

# Create the function to create and post the request
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}


#Start Scan for O365 POP3 or MAPI Logins within Last 4 Hours
$tspan = (New-TimeSpan -Hours 4)
$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query "OfficeActivity | where OfficeWorkload == 'Exchange' and Operation == 'MailboxLogin' | where ClientInfoString contains 'POP3' or ClientInfoString contains 'IMAP4' | distinct UserId, ClientIP, Operation, ResultStatus, ClientInfoString" # -Timespan $tspan

#$queryResults.Results | ConvertTo-Json

# Loop through Query Results 
foreach($result in $queryResults.Results) {

    # Obtain the CountryofOrigin from Public IP Calling a API
    $CIP = $result.ClientIP
    $whatispipjson = Invoke-WebRequest -UseBasicParsing -Uri http://ip-api.com/json/$CIP
    $whatispip = $whatispipjson.Content | ConvertFrom-Json
    $country = $whatispip.country

    # If the CountryofOrigin is not the United States then enrich the PS Object with the Country infromation and port into a Log Analytics Custom Table for Sentinel Alerting
    if ($country -notmatch "United States") {
        
        # Add CountryofOrigin Name and Value into PS Object
        $result = Add-Member -InputObject $result -MemberType NoteProperty -Name CountryofOrigin -Value $country -PassThru -Force

        $json = $result | ConvertTo-Json

        # Submit the data to the API endpoint
        Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType        
    }
}

