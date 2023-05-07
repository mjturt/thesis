import joblib
import pandas
from cryptography.fernet import Fernet
from sklearn import linear_model

TRAIN_DATASET = "data/cars1.csv"


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


def train_model(data) -> linear_model.LinearRegression:
    model = linear_model.LinearRegression()
    X, y = build_data(data)
    model.fit(X, y)
    return model


def generate_key() -> bytes:
    key = Fernet.generate_key()
    with open("key.key", "wb") as filekey:
        filekey.write(key)
    return key


def encrypt_model(model):
    joblib.dump(model, "model.pkl", compress=9)
    key = generate_key()
    fernet = Fernet(key)
    with open("model.pkl", "rb") as model_file:
        original = model_file.read()
    encrypted = fernet.encrypt(original)
    with open("model_encrypted", "wb") as encrypted_file:
        encrypted_file.write(encrypted)


def main():
    data = pandas.read_csv(TRAIN_DATASET)
    model = train_model(data)
    encrypt_model(model)


main()
