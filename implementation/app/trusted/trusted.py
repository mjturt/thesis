#!/usr/bin/env python3

import io
import json
import os
import sys
from time import time

import joblib
import pandas
from cryptography.fernet import Fernet
from sklearn.metrics import r2_score

STRICT = False
TEST_DATASET = "/cars2.csv"


def build_data(data) -> tuple:
    X = data[
        [
            "cylinders",
            "displacement",
            "horsepower",
            "weight",
            "acceleration",
            "year",
            "origin",
        ]
    ]
    y = data["mpg"]
    return X, y


def predict(model, raw_data: str) -> tuple:
    data = json.loads(raw_data)
    test_X = pandas.DataFrame(data)
    count = len(data)
    start = time()
    result = model.predict(test_X)
    end = time()
    return list(result), end - start, count, None


def predict_with_dataset(model, test_dataset: str) -> tuple:
    data = pandas.read_csv(test_dataset)
    test_X, test_y = build_data(data)
    count = len(test_X)
    start = time()
    result = model.predict(test_X)
    end = time()
    r2 = r2_score(test_y, result)
    return list(result), end - start, count, r2


def decrypt_model(key: str) -> io.BytesIO:
    with open("/model_encrypted", "rb") as model_file:
        encrypted_model = model_file.read()
    fernet = Fernet(key)
    decrypted_model = fernet.decrypt(encrypted_model)
    model_file_object = io.BytesIO()
    model_file_object.write(decrypted_model)
    model_file_object.seek(0)
    return model_file_object


def compose_result(result: tuple) -> str:
    predictions, elapsed_time, count, r2 = result
    as_dict = {
        "predictions": predictions,
        "time": elapsed_time,
        "count": count,
        "r2": r2,
    }
    return json.dumps(as_dict)


def main():
    if STRICT:
        if not os.path.exists("/dev/attestation/quote"):
            print("Are you running under SGX, with remote attestation enabled?")
            sys.exit(1)
    key = os.environ.get("SECRET_PROVISION_SECRET_STRING", "")
    model_file = decrypt_model(key)
    model = joblib.load(model_file)
    input_data = sys.argv[1]
    if input_data == "--use-dataset":
        result = predict_with_dataset(model, TEST_DATASET)
    else:
        result = predict(model, input_data)
    result_formatted = compose_result(result)
    print(result_formatted)


main()
