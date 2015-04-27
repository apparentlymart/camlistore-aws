
resource "aws_instance" "server" {
    ami = "${lookup(var.ami_id, var.aws_region)}"
    instance_type = "${var.ec2_instance_type}"

    key_name = "${var.ssh_keypair_name}"

    security_groups = ["${var.vpc_security_group_id}"]
    subnet_id = "${var.vpc_subnet_id}"
    associate_public_ip_address = true

    connection {
        user = "admin"
        key_file = "${var.ssh_keypair_private_key_file}"
        host = "${self.public_ip}"
    }

    provisioner "file" {
        source = "${var.server_config_file}"
        destination = "/tmp/camlistore-server-config.json"
    }

    provisioner "file" {
        source = "${var.identity_secret_ring}"
        destination = "/tmp/camlistore-identity-secring.gpg"
    }

    provisioner "remote-exec" {
        script = "${path.module}/scripts/configure-camlistore.sh"
    }

    tags {
        Name = "camlistore-server"
    }
}
