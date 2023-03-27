import pandas
from sklearn import linear_model
import joblib
from cryptography.fernet import Fernet

df = pandas.read_csv("data/cars.csv")

X = df[['Weight', 'Volume']]
y = df['CO2']

regr = linear_model.LinearRegression()
regr.fit(X, y)

joblib.dump(regr, "model.pkl", compress=9)

key = Fernet.generate_key()
fernet = Fernet(key)
with open('key.key', 'wb') as filekey:
   filekey.write(key)

with open('model.pkl', 'rb') as file:
    original = file.read()

encrypted = fernet.encrypt(original)

with open('model_encrypted', 'wb') as encrypted_file:
    encrypted_file.write(encrypted)
