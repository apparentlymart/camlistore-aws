Terraform Module for EC2 Camlistore Server
==========================================

This directory contains a Terraform_ module to start up an EC2 instance running
Camlistore_.

Terraform is an application that allows AWS (and other) resources to be
described as code and then created/updated automatically.

Usage Instructions
------------------

Preparation
^^^^^^^^^^^

Before running a server you'll need to
`install Camlistore locally`_ to get the clients. The rest of these
instructions assume you have the command-line clients available.

If you haven't already, initialize the client config::

    camput init

(If you're not sure if you've run it before, run it anyway. It'll bail out
without changing anything if you already have a valid configuration.)

Look in ``~/.config/camlistore/client-config.json`` and note the value for
``identity``, since we'll want to configure the same identity on the server
later. This is your GPG identity.

Create a Root Terraform Module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The module in this directory needs some supporting resources in your AWS
account in order to work successfully. The recommended way to set this up
is to create your own Terraform root module that then uses the module in
this directory.

A Terraform module is just a directory, so in some other directory (not in
this directory nor in your Camlistore config directory) create a single
file called ``server.tf``, which will for now be the only file in your
local Terraform module.

Its contents will look something like this:

.. code-block:: javascript

    variable "aws_region" {
        # Customize this to your favorite AWS region.
        # (but note that our server AMI isn't available in GovCloud
        # or eu-central-1, so you can't choose these.)
        value = "us-west-2"
    }

    variable "aws_vpc_id" {
        # Put your own VPC Id in here.
        value = "vpc-1234"
    }

    variable "vpc_subnet_id" {
        # Put in here the id of the subnet you want the server to run in.
        # This subnet must belong to the VPC selected above.
        value = "subnet-4321"
    }

    provider "aws" {
        region = "${var.aws_region}"
    }

    module "server" {
        source = "github.com/apparentlymart/camlistore-aws//deploy"
        # (the double-slash above is significant; don't "correct" it)

        aws_region="${var.aws_region}"
        aws_vpc_id="${var.aws_vpc_id}"
        vpc_subnet_id="${var.vpc_subnet_id}"
        server_config_file="${path.module}/server-config.json"
        vpc_security_group_id="${aws_security_group.server}"
        ssh_keypair_name="${aws_key_pair.provisioning.key_name}"
        ssh_keypair_private_key_file="${path.module}/provisioning-private-key"
        identity_secret_ring="~/.config/camlistore/identity-secring.gpg"
    }

    resource "aws_security_group" "server" {
        name = "camlistore-server"
        description = "Makes ports 22 and 3179 accessible to the internet"

        # You may wish to use some more-restrictive access rules here.

        ingress {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
            from_port = 3179
            to_port = 3179
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    resource "aws_key_pair" "provisioning" {
        key_name = "camlistore-provisioning"
        # (we'll fill this in a later step...)
        public_key = "..."
    }

The above configuration refers to a few other files we've not created yet.
These should exist in the same directory as the config file.

First we need to create an SSH key that will be used to log in to the
camlistore server to run the provisioning tasks. (You can also use it to log
in yourself, if you want.)::

    ssh-keygen -f provisioning-private-key

Once you've generated the key, you'll also have a file called
``provisioning-private-key.pub`` whose contents you should paste into the
``public_key`` attribute on the ``aws_key_pair`` in the Terraform config,
and then delete the original file. Keep ``provisioning-private-key`` (no
extension) since we refer to it in the instantiation of the module.

Finally, we need to create a ``server-config.json`` that will configure
the server. Here's a minimal example:

.. code-block:: javascript

    {
        "auth": "userpass:yourname:yourpassword:+localhost",
        "listen": ":3179",
        "identity": "your GPG identity from earlier",
        "identitySecretRing": "/home/camlistore/.config/camlistore/identity-secring.gpg",
        "blobPath": "/home/camlistore/var/camlistore/blobs",
        "sqlite": "/home/camlistore/var/camlistore/camli-index.db"
    }

The above will configure an insecure (non-SSL) server that stores all data
inside the EC2 instance's ephemeral disk. This is not a suitable production
configuration since it will lose all of its data when it is shut down, but it
is enough to test this has all worked.

Run Terraform to Create the Resources
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All of the steps in this section must be run with the ``server.tf`` file and
the various sibling files in the current working directory.

Before running Terraform for the first time remember to obtain this module::

    terraform get

Then you can run Terraform as normal to apply the configuration::

    terraform apply

Once this completes, you should have a Camlistore server running on port
3179 of whatever public IP address ends up assigned to your instance.

Next Steps
^^^^^^^^^^

These instructions have got you a useless, insecure Camlistore server. From
here you'll probably want to update the configuration to use Amazon S3 as
the blob store, and use a Terraform provisioner to install an HTTP certificate
and associated key so you can enable ``https`` in the server config.

Note that since the server config is installed using a Terraform provisioner
it is only installed the first time the instance is booted and each time
it is destroyed and recreated; re-running ``terraform apply`` will not update
it on an already-running server.

To update the config after local changes, you can either taint the server
using ``terraform taint`` (which will cause it to get destroyed and recreated
on the next run) or just ``scp`` the file directly onto the server.

Future Enhancements?
--------------------

It'd be nice if this module could also handle SSL config, but since Terraform
currently lacks any mechanism for conditional configuration it's not possible
to make a config that *optionally* sets up SSL.

If Camlistore one day learns to support EC2 instance IAM roles it'd be nice
to partially-automate the setup of S3 for storage.

.. _Terraform: https://terraform.io/

.. _Camlistore: https://camlistore.org/

.. _`install camlistore locally`: https://camlistore.org/download

