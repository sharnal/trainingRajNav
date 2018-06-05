echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
ZONES=$ZONES
NAME=$NAME
KOPS_STATE_STORE=$KOPS_STATE_STORE" >kops

kops delete cluster --name $NAME --yes

aws s3api delete-bucket --bucket $BUCKET_NAME

aws iam remove-user-from-group --user-name kops --group-name kops

aws iam delete-access-key --user-name kops --access-key-id \
    $(cat kops-creds | jq -r '.AccessKey.AccessKeyId')

aws iam delete-user --user-name kops

aws iam detach-group-policy --group-name kops \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam detach-group-policy --group-name kops \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam detach-group-policy --group-name kops \
    --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess

aws iam detach-group-policy --group-name kops \
    --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

aws iam delete-group --group-name kops

rm -f devops23.*

aws ec2 delete-key-pair --key-name devops23
