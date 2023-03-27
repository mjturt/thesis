import joblib
import pandas
from cryptography.fernet import Fernet
from sklearn import linear_model


def train_model(data):
    X = data[["Weight", "Volume"]]
    y = data["CO2"]
    model = linear_model.LinearRegression()
    model.fit(X, y)
    return model


def generate_key():
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
    data = pandas.read_csv("data/cars.csv")
    model = train_model(data)
    encrypt_model(model)


main()
