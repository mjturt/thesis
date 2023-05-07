import argparse
import time
from subprocess import PIPE, Popen

import pandas
from sklearn.metrics import r2_score

TEST_DATASET = "data/cars2.csv"


def mpg_to_l_per_100_km(mpg):
    return 235.215 / mpg


def cubic_inches_to_cm3(cubic_inches):
    return cubic_inches * 16.387


def hp_to_kw(hp):
    return hp * 0.7457


def pounds_to_kg(pounds):
    return pounds * 0.453592


def fts2_to_ms2(fs):
    return fs * 0.3048


def l_per_100_km_to_mpg(lper100km):
    return 235.215 * lper100km


def cm3_to_cubic_inches(cm3):
    return cm3 / 16.387


def kw_to_hp(kw):
    return kw / 0.7457


def kg_to_pounds(kg):
    return kg / 0.453592


def ms2_to_fts2(ms2):
    return ms2 / 0.3048


def build_data(data):
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


class Car:
    origins = {
        1: "United States",
        2: "Europe",
        3: "Japan",
    }

    def __init__(
        self,
        name,
        cylinders,
        displacement,
        horsepower,
        weight,
        acceleration,
        year,
        origin,
    ):
        self.name = name
        self.cylinders = cylinders
        self.displacement = displacement
        self.horsepower = horsepower
        self.weight = weight
        self.acceleration = acceleration
        self.year = year
        self.origin = origin
        self.mpg = None

    @property
    def get_year(self):
        return int(self.year) + 1900

    @property
    def get_origin(self):
        return self.origins.get(int(self.origin))

    @property
    def si_displacement(self):
        return cubic_inches_to_cm3(self.displacement)

    @property
    def si_power(self):
        return hp_to_kw(self.horsepower)

    @property
    def si_weight(self):
        return pounds_to_kg(self.weight)

    @property
    def si_acceleration(self):
        return fts2_to_ms2(self.acceleration)

    @property
    def l_per_100km(self):
        if self.mpg:
            return mpg_to_l_per_100_km(self.mpg)
        return None

    @property
    def get_consumption_str(self):
        string = "Predicted consumption:"
        if self.mpg:
            return f"{string} {self.mpg:.1f} mpg ({mpg_to_l_per_100_km(self.mpg):.1f} l/100km)"
        return f"{string} No data yet"

    def __repr__(self):
        string = (
            f"Model: {self.name.title()}\n"
            f"Cylinders: {self.cylinders}\n"
            f"Displacement: {self.displacement:.1f} in³ ({self.si_displacement:.1f} cm³)\n"
            f"Power: {self.horsepower:.1f} hp ({self.si_power:.1f} kW)\n"
            f"Weight: {self.weight:.1f} lb ({self.si_weight:.1f} kg)\n"
            f"Acceleration: {self.acceleration:.1f} ft/s² ({self.si_acceleration:.1f} m/s²)\n"
            f"Year: {self.get_year}\n"
            f"Origin: {self.get_origin}"
        )
        if self.mpg:
            string = f"{string}\n{self.get_consumption_str}"
        return string

    def as_test_data(self):
        return [
            [
                self.cylinders,
                self.displacement,
                self.horsepower,
                self.weight,
                self.acceleration,
                self.year,
                self.origin,
            ]
        ]


def manual_car_build():
    name = input("Car model:\n")
    cylinders = input("Cylinders (int):\n")
    displacement = input("Displacement (cm³):\n")
    power = input("Power (kW):\n")
    weight = input("Weight (kg):\n")
    acceleration = input("Acceleration (m/s²):\n")
    year = input("Year (int, e.g. 84):\n")
    origin = input("Origin (1: United States, 2: Europe, 3: Japan):\n")
    return Car(
        name,
        int(cylinders),
        cm3_to_cubic_inches(float(displacement)),
        kw_to_hp(float(power)),
        kg_to_pounds(float(weight)),
        ms2_to_fts2(float(acceleration)),
        float(year),
        int(origin),
    )


def test_predict(model):
    print("Enter the car details")
    test_car = manual_car_build()
    test_data = test_car.as_test_data()
    start = time.time()
    result = model.predict(test_data)[0]
    end = time.time()
    test_car.mpg = result
    print("For a car:\n")
    print(f"{test_car}\n")
    print(f"The predicted consumption is {test_car.l_per_100km:.1f} km/100l")
    print(f"The prediction calculation took time {end - start:.6f} seconds")


def test_predict_with_dataset(model, test_dataset):
    data = pandas.read_csv(test_dataset)
    test_X, test_y = build_data(data)
    count = len(test_X)
    start = time.time()
    y_pred = model.predict(test_X)
    end = time.time()
    print(
        f"Consumption prediction calculation for {count} car instances took {end - start:.6f} seconds"
    )
    r2 = r2_score(test_y, y_pred)
    print(f"R2 score: {r2:.5f}")


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--test", action="store_true")
    parser.add_argument(
        "-m",
        "--method",
        choices=["dataset", "manual"],
        default="manual",
        required=False,
    )
    return parser.parse_args()


def main():
    p = Popen(["gramine-sgx", "python", "app.py"], cwd="trusted", stdout=PIPE)
    p.wait()
    text = p.communicate()[0]
    print(text)
    print(text.splitlines()[-1])
    test_args = parse_arguments()
    is_test = test_args.test
    test_method = test_args.method


main()
