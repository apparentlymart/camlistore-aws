
variable "aws_region" {
    description = "The AWS region to install into. Only us-west-2 is supported at this time."
}

variable "aws_vpc_id" {
    description = "The VPC to install the Camlistore server into"
}

variable "vpc_subnet_id" {
    description = "The AWS subnet to install the Camlistore server into. This subnet must belong to the VPC given in aws_vpc_id."
}

variable "ami_id" {
    description = "The Camlistore server AMI to use"
    default = {
        ap-northeast-1 = "ami-26c60626"
        ap-southeast-1 = "ami-24350976"
        ap-southeast-2 = "ami-ef0f73d5"
        eu-west-1 = "ami-99066aee"
        us-east-1 = "ami-42fbf92a"
        us-west-1 = "ami-21a44865"
        us-west-2 = "ami-59211669"
        sa-east-1 = "ami-f38a0eee"
    }
}

variable "server_config_file" {
    description = "Path to a server-config.json file that will be used for the new Camlistore server (changing this after initial deployment requires the server to be rebuilt)"
}

variable "identity_secret_ring" {
    description = "Path to an identity-secring.json file that will be installed as the camlistore identity in /home/camlistore/.config/camlistore/identity-secring.gpg"
}

variable "vpc_security_group_id" {
    description = "Security group (which must belong to the VPC given in aws_vpc_id) to use for the created server instance"
}

variable "ec2_instance_type" {
    description = "Type of EC2 instance to create"
    default = "t2.micro"
}

variable "ssh_keypair_name" {
    description = "Name of a previously-created SSH keypair to use for the instance"
}

variable "ssh_keypair_private_key_file" {
    description = "Location of the file containing the private key from the SSH keypair given in ssh_keypair_name"
}

output "aws_instance_id" {
    value = "${aws_instance.server.id}"
}

output "public_ip" {
    value = "${aws_instance.server.public_ip}"
}

output "private_ip" {
    value = "${aws_instance.server.private_ip}"
}
