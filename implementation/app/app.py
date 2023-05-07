import argparse
import json
from subprocess import PIPE, Popen
from time import time

import joblib
import pandas
from sklearn.metrics import r2_score

TEST_DATASET = "trusted/cars2.csv"
TEST_MODEL = "../model-trainer/model.pkl"


def mpg_to_l_per_100_km(mpg: float) -> float:
    return 235.215 / mpg


def cubic_inches_to_cm3(cubic_inches: float) -> float:
    return cubic_inches * 16.387


def hp_to_kw(hp: float) -> float:
    return hp * 0.7457


def pounds_to_kg(pounds: float) -> float:
    return pounds * 0.453592


def fts2_to_ms2(fs: float) -> float:
    return fs * 0.3048


def l_per_100_km_to_mpg(lper100km: float) -> float:
    return 235.215 * lper100km


def cm3_to_cubic_inches(cm3: float) -> float:
    return cm3 / 16.387


def kw_to_hp(kw: float) -> float:
    return kw / 0.7457


def kg_to_pounds(kg: float) -> float:
    return kg / 0.453592


def ms2_to_fts2(ms2: float) -> float:
    return ms2 / 0.3048


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
    def get_year(self) -> int:
        return int(self.year) + 1900

    @property
    def get_origin(self) -> str:
        return self.origins.get(int(self.origin), "Unknown")

    @property
    def si_displacement(self) -> float:
        return cubic_inches_to_cm3(self.displacement)

    @property
    def si_power(self) -> float:
        return hp_to_kw(self.horsepower)

    @property
    def si_weight(self) -> float:
        return pounds_to_kg(self.weight)

    @property
    def si_acceleration(self) -> float:
        return fts2_to_ms2(self.acceleration)

    @property
    def l_per_100km(self) -> float | None:
        if self.mpg:
            return mpg_to_l_per_100_km(self.mpg)
        return None

    @property
    def get_consumption_str(self) -> str:
        string = "Predicted consumption:"
        if self.mpg:
            return f"{string} {self.mpg:.1f} mpg ({mpg_to_l_per_100_km(self.mpg):.1f} l/100km)"
        return f"{string} No data yet"

    def __repr__(self) -> str:
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

    def as_test_data(self) -> list[list]:
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


def manual_car_build() -> Car:
    print("Please enter the following data for a car:\n")
    name = input("Car model (str): ")
    cylinders = input("Cylinders (int): ")
    displacement = input("Displacement (cm³): ")
    power = input("Power (kW): ")
    weight = input("Weight (kg): ")
    acceleration = input("Acceleration (m/s²): ")
    year = input("Year (int, e.g. 84): ")
    origin = input("Origin (1: United States, 2: Europe, 3: Japan): ")
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


def run_gramine(arg: str) -> bytes:
    pipe = Popen(
        ["gramine-sgx", "python", "trusted.py", arg], cwd="trusted", stdout=PIPE
    )
    pipe.wait()
    text = pipe.communicate()[0]
    data = text.splitlines()[-1]
    return data


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


def predict(model, data: list) -> tuple:
    count = len(data)
    start = time()
    result = model.predict(data)[0]
    end = time()
    return result, end - start, count, None


def predict_with_dataset(model, test_dataset: str) -> tuple:
    data = pandas.read_csv(test_dataset)
    test_X, test_y = build_data(data)
    count = len(test_X)
    start = time()
    result = model.predict(test_X)
    end = time()
    r2 = r2_score(test_y, result)
    return list(result), end - start, count, r2


def compose_result(result: tuple) -> str:
    predictions, elapsed_time, count, r2 = result
    if predictions is not list:
        predictions = [predictions]
    as_dict = {
        "predictions": predictions,
        "time": elapsed_time,
        "count": count,
        "r2": r2,
    }
    return json.dumps(as_dict)


def print_results(data: dict, car: Car | None):
    if car:
        print("For a car:\n")
        print(f"{car}\n")
        print(f"The predicted consumption is {car.l_per_100km:.1f} km/100l")
        print(f"The prediction calculation took {data['time']:.6f} seconds")
    else:
        print(
            f"Consumption prediction calculation for {data['count']} car instances"
            f" took {data['time']:.6f} seconds"
        )
        print(f"R2 score: {data['r2']:.2f}")


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--dataset", action="store_true")
    parser.add_argument("-n", "--nosgx", action="store_true")
    return parser.parse_args()


def main():
    args = parse_arguments()
    use_dataset = args.dataset
    no_sgx = args.nosgx
    car = None
    if use_dataset:
        if no_sgx:
            print(
                "Note: Not using Intel SGX. Calculating data for dataset"
                f" {TEST_DATASET} locally.\n"
            )
            model = joblib.load(TEST_MODEL)
            data_as_tuple = predict_with_dataset(model, TEST_DATASET)
            raw_data = compose_result(data_as_tuple)
        else:
            print(
                f"Sending dataset {TEST_DATASET} to the Gramine Intel SGX enclave"
                " for calculation...\n"
            )
            print("--- START OF GRAMINE OUTPUT ---\n")
            raw_data = run_gramine("--use-dataset")
            print("\n--- END OF GRAMINE OUTPUT ---\n")
        data = json.loads(raw_data)
    else:
        car = manual_car_build()
        print(f"\n{car}\n")
        input_data = json.dumps(car.as_test_data())
        data = json.loads(input_data)
        if no_sgx:
            print(
                "Note: Not using Intel SGX. Calculating data for above car locally.\n"
            )
            model = joblib.load(TEST_MODEL)
            data_as_tuple = predict(model, car.as_test_data())
            raw_data = compose_result(data_as_tuple)
        else:
            print(
                "Sending the above car data to the Gramine Intel SGX enclave for"
                " calculation...\n"
            )
            print("--- START OF GRAMINE OUTPUT ---\n")
            raw_data = run_gramine(input_data)
            print("\n--- END OF GRAMINE OUTPUT ---\n")
        data = json.loads(raw_data)
        car.mpg = data["predictions"][0]
    print_results(data, car)


main()
