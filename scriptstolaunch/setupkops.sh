aws ec2 describe-availability-zones --region $AWS_DEFAULT_REGION

export ZONES=$(aws ec2 describe-availability-zones --region $AWS_DEFAULT_REGION | jq -r '.AvailabilityZones[].ZoneName' | tr '\n' ',' | tr -d ' ')

ZONES=${ZONES%?}

echo $ZONES

aws ec2 create-key-pair --key-name devops23 | jq -r '.KeyMaterial' >devops23.pem

chmod 400 devops23.pem

ssh-keygen -y -f devops23.pem >devops23.pub

aws s3api create-bucket --bucket $BUCKET_NAME \
    --create-bucket-configuration \
    LocationConstraint=$AWS_DEFAULT_REGION

# kops create cluster --name $NAME --master-count 3 --node-count 1 \
#     --node-size t2.small --zones $ZONES \
#     --master-zones $ZONES --ssh-public-key devops23.pub --authorization RBAC \
#     --networking kubenet --yes

kops create cluster --name $NAME --master-count 3 --node-count 1 \
    --node-size t2.small --zones $ZONES \
    --master-zones $ZONES --ssh-public-key devops23.pub --authorization RBAC \
    --networking kubenet --yes

until kops get cluster
do
    echo "Cluster is not yet ready. Sleeping for a while..."
    sleep 30
done

until kubectl cluster-info
do
    echo "Cluster is not yet ready. Sleeping for a while..."
    sleep 30
done

until kops validate cluster
do
    echo "Cluster is not yet ready. Sleeping for a while..."
    sleep 30
done


