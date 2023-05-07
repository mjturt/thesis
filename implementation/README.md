# Implementation

This is a reference implementation on how to use Trusted Execution Environments
to protect Intellectual Property of ML models. Intel SGX is used as Trusted
Exectuion Environment.

Implementation consist of three parts: the main application (app), key-server
and model-trainer.

Details can be read from the [thesis's](../thesis) Solution section.

## Build

To build and run all three parts on the same machine the `build.sh` script can
be used. Of course, this is not the way this solution would be run in production.

Working Intel SGX setup is required.

First copy `settings.sh-example` to `settings.sh` and configure it. Free subscription
to the Intel's remote attestation service can be obtained at
[Intel Trusted Services Portal](https://api.portal.trustedservices.intel.com/).
Values needed for `settings.sh` can be obtained from Trusted Services Portal.

Then run `build.sh` script. The script tells what to do after build.
