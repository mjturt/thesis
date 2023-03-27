#!/usr/bin/env python3

import os
import sys

if not os.path.exists("/dev/attestation/quote"):
    print("Cannot find `/dev/attestation/quote`; "
          "are you running under SGX, with remote attestation enabled?")
    sys.exit(1)

print(f"Key: {os.environ.get('SECRET_PROVISION_SECRET_STRING')}")
