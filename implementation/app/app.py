import argparse
import json
import os
from subprocess import PIPE, Popen

TEST_DATASET_NAME = "cars2.csv"

# Used for test without Intel SGX
TEST_KEY = "../model-trainer/key.key"


def mpg_to_l_per_100_km(mpg: float) -> float:
    return round(235.215 / mpg, 1)


def cubic_inches_to_cm3(cubic_inches: float) -> float:
    return round(cubic_inches * 16.387, 1)


def hp_to_kw(hp: float) -> float:
    return round(hp * 0.7457, 1)


def pounds_to_kg(pounds: int) -> int:
    return round(pounds * 0.453592)


def fts2_to_ms2(fs: float) -> float:
    return round(fs * 0.3048, 1)


def l_per_100_km_to_mpg(lper100km: float) -> float:
    return round(235.215 * lper100km, 1)


def cm3_to_cubic_inches(cm3: float) -> float:
    return round(cm3 / 16.387, 1)


def kw_to_hp(kw: float) -> float:
    return round(kw / 0.7457, 1)


def kg_to_pounds(kg: int) -> int:
    return round(kg / 0.453592)


def ms2_to_fts2(ms2: float) -> float:
    return round(ms2 / 0.3048, 1)


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
    def si_weight(self) -> int:
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

    def as_ml_data(self) -> dict:
        return {
            "cylinders": [self.cylinders],
            "displacement": [self.displacement],
            "horsepower": [self.horsepower],
            "weight": [self.weight],
            "acceleration": [self.acceleration],
            "year": [self.year],
            "origin": [self.origin],
        }


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
        kg_to_pounds(int(weight)),
        ms2_to_fts2(float(acceleration)),
        int(year),
        int(origin),
    )


def run_trusted(arg: str, sgx=True) -> bytes:
    cmds = ["python", "trusted.py", arg]
    env_mod = os.environ.copy()
    if sgx:
        cmds.insert(0, "gramine-sgx")
    else:
        with open(TEST_KEY, "r") as key_file:
            key_str = key_file.read().strip()
            env_mod["SECRET_PROVISION_SECRET_STRING"] = key_str
    pipe = Popen(cmds, cwd="trusted", stdout=PIPE, env=env_mod)
    pipe.wait()
    text = pipe.communicate()[0]
    data = text.splitlines()[-1]
    return data


def print_results(data: dict, car: Car | None):
    if car:
        print("For a car:\n")
        print(f"{car}\n")
        print(f"The predicted consumption is {car.l_per_100km:.1f} l/100km")
        print(f"The prediction calculation took {data['time']:.6f} seconds")
    else:
        print(
            f"Consumption prediction calculation for {data['count']} car instances"
            f" took {data['time']:.6f} seconds"
        )
        print(f"R2 score: {data['r2']:.2f}")


def parse_arguments():
    parser = argparse.ArgumentParser(
        prog="app.py",
        description=str(
            "Predicts the consumption of a car based on its data. The calculations are done"
            " in an Intel SGX enclave. Can either use manually entered data or a dataset."
            " Can also be run without Intel SGX."
        ),
    )
    parser.add_argument(
        "-d",
        "--dataset",
        action="store_true",
        help=f"Use dataset ({TEST_DATASET_NAME})",
    )
    parser.add_argument(
        "-n", "--nosgx", action="store_true", help="Do not use Intel SGX"
    )
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
                f" {TEST_DATASET_NAME} locally.\n"
            )
            raw_data = run_trusted("--use-dataset", sgx=False)
        else:
            print(
                f"Sending dataset {TEST_DATASET_NAME} to the Gramine Intel SGX enclave"
                " for calculation...\n"
            )
            print("--- START OF GRAMINE OUTPUT ---\n")
            raw_data = run_trusted("--use-dataset")
            print("\n--- END OF GRAMINE OUTPUT ---\n")
        data = json.loads(raw_data)
    else:
        car = manual_car_build()
        input_data = json.dumps(car.as_ml_data())
        data = json.loads(input_data)
        if no_sgx:
            print(
                "\nNote: Not using Intel SGX. Calculating data for above car locally.\n"
            )
            raw_data = run_trusted(input_data, sgx=False)
        else:
            print(
                "Sending the above car data to the Gramine Intel SGX enclave for"
                " calculation...\n"
            )
            print("--- START OF GRAMINE OUTPUT ---\n")
            raw_data = run_trusted(input_data)
            print("\n--- END OF GRAMINE OUTPUT ---\n")
        data = json.loads(raw_data)
        car.mpg = data["predictions"][0]
    print_results(data, car)


main()
