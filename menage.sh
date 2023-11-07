#!/bin/bash
echo "---------------------------------------"
echo "------ Welcome to VPN Automation ------"
echo "---------------------------------------"
echo
echo "*** check conf ..."
echo "*** is aws cli installed ? "
aws --version
echo "*** is Terraform installed ? "
terraform --version
echo "*** is python installed ? "
python3 --version
echo "*** is Ansible installed ? "
ansible --version
echo
echo "*** check credentials ..."
echo "*** on aws side :"
aws sts get-caller-identity
echo "*** on ovh side :"
echo $OS_AUTH_URL
echo $OS_USERNAME
echo $OS_REGION_NAME
if [[ -z $OS_REGION_NAME ]]; then
    echo "where are you ??? "
fi
ouijeveuxcontinuer="yes"
echo
echo "So, "
echo "Would you like to continue ? Only 'yes' will be accepted to confirm"
read continuer
if [ "$continuer" == "$ouijeveuxcontinuer" ]; then
    echo "ok, let s go"

    terraform init
    terraform destroy -auto-approve | tee selfmenage.out

    echo
    echo "------------------------------"
    echo "------ that s all folks ------"
    echo "------------------------------"
else
    echo "bye :-("
fi