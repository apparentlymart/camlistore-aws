camlistore AMI packer config
============================

This is a packer configuration for building an Amazon Machine Image (AMI) with
camlistore preinstalled.

To use it, you must first install `Packer <https://packer.io/>`.

Then set the ``AWS_ACCESS_KEY_ID`` and ``AWS_SECRET_ACCESS_KEY`` environment
variables to appropriate AWS credentials.

Create a file called ``vars.json`` that contains something like this, using
actual values from your own AWS account:

.. code-block:: javascript

    {
        "aws_vpc_id": "vpc-12345",
        "aws_subnet_id": "subnet-12345",
        "aws_region": "us-west-2"
    }

(Sticking with ``us-west-2`` as the region is the easiest, since that's where
the default source AMI comes from. If you change it you'll also need to set
``source_ami`` to the Debian corresponding Jessie AMI for the region you've
selected.)

Once you've got all this in place you can then run packer::

    packer build -var-file=vars.json camlistore-server.json

If it runs successfully to completion then you will get the id of an AMI that
has the camlistore binaries in ``/usr/local/bin`` and the necessary files for
the web UI in ``/usr/local/lib/camlistore``. A system user is also created,
called ``camlistore``, which should be used to run camlistore in preference
to ``admin``, since Camlistore does not deserve nor want access to run
``sudo``.

Once you've booted the created image you'll need to create a server config
in ``/home/camlistore/.config/camlistore/server-config.json``, which should
have the ``sourceRoot`` property set to ``/usr/local/lib/camlistore``.
You can then run ``camlistored`` (as the user ``camlistore``) to start up the
Camlistore server using that configuration.

Have fun!
