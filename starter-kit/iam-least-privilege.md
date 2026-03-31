The least privilege grants only the minimum permissions required for the application task. In this case, reading from a specific S3 bucket and writing logs to CloudWatch while explicitly avoiding unnecessary or broad access. The specific task is kk-api service needs to read product/payment data from S3 and write logs to CloudWatch.
Create trust policy(EC2): nano trust.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
Create IAM permission policy: nano policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlySpecificBucket",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::kijani-data-bucket/*"
    },
    {
      "Sid": "AllowListBucket",
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::kijani-data-bucket"
    },
    {
      "Sid": "WriteApplicationLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:af-south-1:*:log-group:/kijani/api:*"
    }
  ]
}
Create the IAM Role:
aws iam create-role \
  --role-name KijaniApiRole \
  --assume-role-policy-document file://trust.json
Attach policy:
aws iam put-role-policy \
  --role-name KijaniApiRole \
  --policy-name KijaniApiLeastPrivilege \
  --policy-document file://policy.json
