### STILL IN DEVELOPMENT
Testing with Terraform to create an AWS VPN server with wireguard.

To use this setup, clone this repository.  Setup your AWS AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY any way you wish. For fast use in Linux use the following:
```
export AWS_ACCESS_KEY_ID=<Key ID from AWS>
export AWS_SECRET_ACCESS_KEY=<Secret Key from AWS>
```

Then run `terraform init` to create the Terraform environment.

Now if you have a domain name you want to use to reach your AWS instance you will want to use it in the apply command. This is passed to the docker variable that tells wireguard what its FQDN is for client profiles.
`terraform apply `

Once the EC2 instance is up and running, you can ssh to it useing: 

`ssh -i mykey.pem ubuntu@$(terraform output -raw public_ip)`
