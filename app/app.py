#!/usr/bin/env python3

import io
import os
import sys

import joblib
from cryptography.fernet import Fernet


def decrypt_model(key) -> io.BytesIO:
    with open("/model_encrypted", "rb") as model_file:
        encrypted_model = model_file.read()
    fernet = Fernet(key)
    decrypted_model = fernet.decrypt(encrypted_model)
    model_file_object = io.BytesIO()
    model_file_object.write(decrypted_model)
    model_file_object.seek(0)
    return model_file_object


def main():
    if not os.path.exists("/dev/attestation/quote"):
        print("Are you running under SGX, with remote attestation enabled?")
        sys.exit(1)
    key = os.environ.get("SECRET_PROVISION_SECRET_STRING", "")
    model_file = decrypt_model(key)
    model = joblib.load(model_file)
    predictedCO2 = model.predict([[2300, 1300]])
    print(f"PREDICTION: {predictedCO2}")

main()
