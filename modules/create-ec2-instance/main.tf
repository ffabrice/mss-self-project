# create EC2 instance

# Create vpc resource 
resource "aws_vpc" "awsvpc-tf-sell" {
  cidr_block = var.aws_cidr_vpc
  
  tags = {
    Name = "${var.aws_pod}-${var.aws_vpc_sufx}"
  }
  
}

# Create subnet 1 public
resource "aws_subnet" "aws-public-subnet-tf-sell" {
  vpc_id     = resource.aws_vpc.awsvpc-tf-sell.id
  cidr_block = var.aws_cidr_public

  tags = {
    Name = "${var.aws_pod}-${var.aws_subnet_public_sufx}"
  }
}

# Create subnet 2 private
resource "aws_subnet" "aws-private-subnet-tf-sell" {
  vpc_id     = resource.aws_vpc.awsvpc-tf-sell.id
  cidr_block = var.aws_cidr_private

  tags = {
    Name = "${var.aws_pod}-${var.aws_subnet_private_sufx}"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "aws-igw-tf-sell" {
  vpc_id     = resource.aws_vpc.awsvpc-tf-sell.id

  tags = {
    Name = "${var.aws_pod}-${var.aws_internet_gateway_sufx}"
  }
}

# Create public route table
resource "aws_route_table" "aws-public-routetable-tf-sell" {
  vpc_id     = resource.aws_vpc.awsvpc-tf-sell.id
  
  route {
    cidr_block = var.aws_public_routetable_cidr_block
    gateway_id = resource.aws_internet_gateway.aws-igw-tf-sell.id
  }

  tags = {
    Name = "${var.aws_pod}-${var.aws_public_routetable_sufx}"
  }
}

# Create route table association with subnet
resource "aws_route_table_association" "aws-rtasso-tf-sell-wsub" {
  subnet_id = resource.aws_subnet.aws-public-subnet-tf-sell.id
  route_table_id = resource.aws_route_table.aws-public-routetable-tf-sell.id
}

# Create a security group for ssh
resource "aws_security_group" "aws-sg-ssh-tf-sell" {
  vpc_id      = resource.aws_vpc.awsvpc-tf-sell.id
  name        = "allow_ssh"
  description = "allow ssh pour ipv4"

  ingress {
    description = "ssh for ipv4"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [data.aws_vpc.awsvpc-tf-sel.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow any"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_pod}-${var.aws_security_group_sufx_ssh}"
  }
}

# Create a security group for RDP
resource "aws_security_group" "aws-sg-rdp-tf-sell" {
  vpc_id      = resource.aws_vpc.awsvpc-tf-sell.id
  name        = "allow_rdp"
  description = "allow rdp pour ipv4"

  ingress {
    description = "rdp for all"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow any"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_pod}-${var.aws_security_group_sufx_rdp}"
  }
}

# Create a security group for icmp
resource "aws_security_group" "aws-sg-icmp-tf-sell" {
  vpc_id      = resource.aws_vpc.awsvpc-tf-sell.id
  name        = "allow_icmp"
  description = "allow icmp pour ipv4"

  ingress {
    description = "icmp for all"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow any"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_pod}-${var.aws_security_group_sufx_icmp}"
  }
}

# Create a security group for http
resource "aws_security_group" "aws-sg-http-tf-sell" {
  vpc_id      = resource.aws_vpc.awsvpc-tf-sell.id
  name        = "allow_http"
  description = "allow http pour ipv4"

  ingress {
    description = "http for ipv4"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = [data.aws_vpc.awsvpc-tf-sel.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow any"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_pod}-${var.aws_security_group_sufx_http}"
  }
}

# Create a security group for https
resource "aws_security_group" "aws-sg-https-tf-sell" {
  vpc_id      = resource.aws_vpc.awsvpc-tf-sell.id
  name        = "allow_https"
  description = "allow https pour ipv4"

  ingress {
    description = "https for ipv4"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    #cidr_blocks = [data.aws_vpc.awsvpc-tf-sel.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow any"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_pod}-${var.aws_security_group_sufx_http}"
  }
}

# Create a RSA key pair 4096 bits 
resource "tls_private_key" "aws-keypair-rsa-tf-sell" {
  algorithm = var.aws_algorithm_name
  rsa_bits = var.aws_rsa_bits
}

# Create a local file to save the private key
resource "local_file" "aws-private-key-file-tf-sell" {
  content = resource.tls_private_key.aws-keypair-rsa-tf-sell.private_key_pem
  filename = var.ssh_aws_private_key_filename
  file_permission = "0600"
}

# Create a aws key pair
resource "aws_key_pair" "aws-public-key-tf-sell" {
  key_name = "${var.aws_pod}${var.ssh_aws_key_name_sufx}"
  public_key = resource.tls_private_key.aws-keypair-rsa-tf-sell.public_key_openssh

  tags = {
    Name = "${var.aws_pod}${var.ssh_aws_key_name_sufx}"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = var.aws_ami_filter_name_name
    values = [var.aws_ami_filter_name_value]
  }

  filter {
    name   = var.aws_ami_filter_architecture_name
    values = [var.aws_ami_filter_architecture_value]
  }

  owners = [var.aws_ami_owner] # Canonical
}

# Create a EC2 instance 
resource "aws_instance" "aws-ec2-instance-tf-sell" {
  
  ami = data.aws_ami.ubuntu.id
  instance_type = var.aws_ec2_instance_type

  subnet_id = resource.aws_subnet.aws-public-subnet-tf-sell.id
  vpc_security_group_ids = [resource.aws_security_group.aws-sg-ssh-tf-sell.id,
                            resource.aws_security_group.aws-sg-rdp-tf-sell.id,
                            resource.aws_security_group.aws-sg-icmp-tf-sell.id,
                            resource.aws_security_group.aws-sg-http-tf-sell.id,
                            resource.aws_security_group.aws-sg-https-tf-sell.id]
  
  key_name = resource.aws_key_pair.aws-public-key-tf-sell.key_name

  associate_public_ip_address = true

  source_dest_check = false

  tags = {
    Name = "${var.aws_pod}-${var.aws_ec2_instance_sufx}"
  }
}

# get aws route53 zone 
data "aws_route53_zone" "selected" {
  name         = "${var.aws_dns_zone}"
}

# Create a Route53 resource
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.aws_dns_record}.${var.aws_dns_zone}"
  type    = "A"
  ttl     = 300
  records = [resource.aws_instance.aws-ec2-instance-tf-sell.public_ip]
}

# attache EC2 role to our instance
resource "terraform_data" "instance_role" {
  # ...

  provisioner "local-exec" {
    command = "aws ec2 associate-iam-instance-profile --iam-instance-profile Name=r53-devops --instance-id ${resource.aws_instance.aws-ec2-instance-tf-sell.id} --region ${var.aws_region}"
  }
}

# Capture vpc_id in output variable
output "vpc_id" {
  value = resource.aws_vpc.awsvpc-tf-sell.id
}

# Capture vpc_cidr_block in output variable
output "vpc_cidr_block" {
  value = resource.aws_vpc.awsvpc-tf-sell.cidr_block
}

# Capture ec2 instance id in output variable
output "ec2_id" {
  value = resource.aws_instance.aws-ec2-instance-tf-sell.id
}

# Capture public ip in output variable
output "public_ip" {
  value = resource.aws_instance.aws-ec2-instance-tf-sell.public_ip
}
