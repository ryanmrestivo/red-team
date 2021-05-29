<#
    .DESCRIPTION
        A script to export all the azure policy resources for use with offline and github

    .NOTES
        AUTHOR: Nathan Swift
        LASTEDIT: Jan 16, 2021
        FUTURES: 
            1. export initiatives and assignments
            2. integrate and push into github repo
            3. generate markdown and category
            4. convert targeted builtins into customs
            5. general error handling and folder \ file overwrite
#>

#Inspired from: https://docs.microsoft.com/en-us/azure/governance/policy/how-to/export-resources

# place to export locally
$path = 'C:\temp\policyexports\policies\'

#collect all custom policy defintions, could place a # before | where to collect all definitions
$policydefs = Get-AzPolicyDefinition | Where-Object {$_.Properties.PolicyType -match 'Custom' }


## Future sections
#$initiatives = Get-AzPolicySetDefinition
#$assignments = Get-AzPolicyAssignment

# loop through to export
foreach ($policydef in $policydefs){

    <# 
    .ERROR HANDLING NEEDED:
        1. New-Item : The given path's format is not supported
        2. Out-File : Cannot perform operation because the wildcard path
    #>

    # unique policy display name and guid for folder creation
    $folderpath = $path + $policydef.Properties.DisplayName + '_' + $policydef.Name

    #create folder
    New-Item $folderpath -itemtype directory

    #export and create azure policy in proper path
    $filepath = $folderpath + '\policy.json'
    $policydef | ConvertTo-Json -Depth 10 | Out-File -FilePath $filepath

    ## Future use with category and markdown file generation
    #$policydefs[0].Properties.Metadata.category

}