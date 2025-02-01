# acit_4640_lab_4
in class terraform / aws lab

# set up instructions
Make sure terraform is installed locally
## cloud-config file
Here you need to add the contents of the ssh public key and packages you wish to install

#Instructions on general set up.
## main.tf
Here we are creating an ec2 instance. 
Must add tags to most blocks with the project name
Availability zone needs to be configured in order to receive public ip addresses
The gateway and route table must be associated with the VPC and subnet, using the aws_vpc.web.id variable to retrieve the vpc_id from previous configurations.

The aws_route block should correctly reference the internet gateway, specifying a cidr_block and route_table_id, which should be obtained using aws_route_table.web.id.

The security group (aws_security_group) should link VPC by using aws_vpc.web.id to getthe corresponding ID.

EC2 settings should be configured using the previously defined AMI variable, along with the instance type, subnet ID, and security group. The public key is referenced in the .yaml file rather than being directly specified in the EC2 block.

# Command used to create a new SSH key pair.
  ssh-keygen -t ed25519 -f ~/.ssh/<key-name> -C "<commnet-to-identify-key>"

# Commands used to initialize, fmt, plan... configuration.
  -terraform init to initialize the directory
  -terraform plan
  -terraform validate to make sure main.tf is correct syntax wise
  -terraform apply to run main.tf to create our instance

      

