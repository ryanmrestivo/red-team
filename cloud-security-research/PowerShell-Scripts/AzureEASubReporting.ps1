
## Script is used to query https://consumption.azure.com/v1/enrollments/{enrollmentID}/usagedetails
## Script reaches out and returns active consumption for the current month and pushes a table for enterprise knowledge purposes and future configuration of Subs
## Can be used in subscription sprawl enviroments to see what Subs are consuming, organize how Subs are configured in Enterprise

# EA Consumption API variables
$EnrollmentNumber="..."
$AccessKey="..."


#Base URL: https://consumption.azure.com/v1/enrollments/{enrollmentID}/usagedetails
# Create URL and Auth for invoking
$BaseUrl = "https://consumption.azure.com/v1/enrollments/"

$AuthHeaders = @{"authorization"="bearer $AccessKey"}

$Url= $BaseUrl + $EnrollmentNumber + "/usagedetails"

# Create an array for object data responses
$dataarray = @()

# Continue logic variable for DO
$continuationToken = ""

#Iterate untill API Call does not respond with a next link, or nextlink=null
Do { 

    # Call EA Consumption API
    $Response = Invoke-WebRequest $Url -Headers $AuthHeaders

    # Convert response from JSON to Table for a NextLink check variable
    $links = $Response.Content | ConvertFrom-Json

    # Convert response from JSON to Table for Object, peer into the data responses
    $responsedata = $Response.Content | ConvertFrom-Json | select-Object -Expand Data

    #Append data responses of object into array
    $dataarray += $responsedata

    # Time to check if there is more data API results batched at 1000, with a Next Link
if ($Url = $links.nextLink) {
        $continuationToken = `
            [System.Web.HttpUtility]::`
            UrlDecode($links.NextLink.Split("=")[-1])
    } else {
        $continuationToken = ""
    }
} until (!$continuationToken)

# Let's get unique with the table
$cleandataaarray = $dataarray | Select accountOwnerEmail,subscriptionGuid,subscriptionName -Unique
