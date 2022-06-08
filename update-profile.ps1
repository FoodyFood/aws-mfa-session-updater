# Created to update your .aws/config and .aws/credentials for CLI sessions with MFA enabled
# This will use token code from args[0], input_profile to be used as args[1], profile to be updated in aws credentials as the args[2]
# 

#Check if args are provided
if ($args.Count -eq 0) {
  echo "Usage; put your one time code at the end like so: aws-mfa-session-updater.ps1 123456"
  exit
}

$inputAwsProfile = $args[0]   # For example mypersonalprofilename or, default
$outputAwsProfile = $args[1]
$callerIdentity = aws sts get-caller-identity --profile $inputAwsProfile | ConvertFrom-Json
$serialNumber = $callerIdentity.Arn -replace "user", "mfa"

echo "Getting sts session token with serial number:  "$serialNumber""
$ErrorActionPreference = "Stop"
$sessionToken = aws sts get-session-token --serial-number $serialNumber --token-code $args[2] --profile $inputAwsProfile | ConvertFrom-Json

echo $sessionToken.Credentials

aws configure set aws_access_key_id $sessionToken.Credentials.AccessKeyId --profile $outputAwsProfile
aws configure set aws_secret_access_key $sessionToken.Credentials.SecretAccessKey --profile $outputAwsProfile
aws configure set aws_session_token $sessionToken.Credentials.SessionToken --profile $outputAwsProfile

echo "updated profile $outputAwsProfile"
