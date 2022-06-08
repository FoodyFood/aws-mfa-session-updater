# Created to update your .aws/config and .aws/credentials for CLI sessions with MFA enabled
# This will create a $awsProfile-mfa profile or update the current one as needed
# 


# Edit these as needed:
$awsProfile = $("profile-name")    # For example numerix or, default
$userAccountName = $("aws-user-name")  # For example doconnor
$awsAccountNumber = $("123456789")


#Check a one-time code was provided as arg[0]
if ($args.Count -eq 0) {
  echo "Usage; put your one time code at the end like so: aws-mfa-session-updater.ps1 123456"
  exit
}


# Checking the validity of the initial profile to get the mfa session from
echo "Caller identity using the profile: $awsProfile"
aws sts get-caller-identity --profile $awsProfile

# Grab a token
$serialNumber = "arn:aws:iam::" + $awsAccountNumber + ":mfa/" + $userAccountName
$sessionToken = aws sts get-session-token --serial-number $serialNumber --token-code $args[0] --profile $awsProfile
echo ""


# Split it into parts and update your aws config files
$ErrorActionPreference = 'silentlycontinue'
$splitToken = $($sessionToken -replace '\s+', ' ').split()
aws configure set region us-west-1 --profile $awsProfile-mfa
aws configure set output text --profile $awsProfile-mfa
aws configure set aws_access_key_id $splitToken[1] --profile $awsProfile-mfa
aws configure set aws_secret_access_key $splitToken[3] --profile $awsProfile-mfa
aws configure set aws_session_token $splitToken[4] --profile $awsProfile-mfa
$ErrorActionPreference = 'Continue'


# Check the mfa session token we got
echo "Caller identity using the $awsProfile-mfa profile:"
aws sts get-caller-identity --profile $awsProfile-mfa
echo "Update attempted, check above for any errors"
