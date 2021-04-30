
# =======================================================================================================================

# Twilio send SMS function:

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check if environment variables are already set or not, and set them if not

$NewEnvVarName = ""
$NewEnvVarValue = ""

Write-Verbose "Setting environment variables: $NewEnvVarName, $NewEnvVarValue"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# -----------------------------------------------------------------------------------------------------------------------

# Update System Environment Variables (add to separate file and run once, make that file private)

#[Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", "your_account_sid", "User")
[Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "User")

#[Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", "your_auth_token", "User")
[Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "User")

# Twilio Phone number to send SMS from
[Environment]::SetEnvironmentVariable("TWILIO_NUMBER", "+12345678901", "User")

# Phone number to send SMS to
[Environment]::SetEnvironmentVariable("TWILIO_VERIFIED_CALLERID", "+12345678901", "User")

# -----------------------------------------------------------------------------------------------------------------------
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
