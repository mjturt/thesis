import random
import sys

import pandas as pd

DEFAULT_COUNT = 1000


def random_float(start: float, end: float) -> float:
    return round(random.uniform(start, end), 1)


def random_int(start: int, end: int) -> int:
    return random.randint(start, end)


def random_car_name() -> str:
    cars = ["Toyota", "Mazda", "BMW", "Mercedes Benz", "Audi", "Volkswagen"]
    return f"{random.choice(cars)} {random_int(100, 1000)}"


def main():
    try:
        count = int(sys.argv[1])
    except Exception:
        count = DEFAULT_COUNT
    df = pd.DataFrame(
        [
            {
                "mpg": random_float(10.0, 50.0),
                "cylinders": random_int(3, 8),
                "displacement": random_float(50.0, 500.0),
                "horsepower": random_float(50.0, 400.0),
                "weight": random_int(1000, 5000),
                "acceleration": random_float(5.0, 20.0),
                "year": random_int(70, 90),
                "origin": random_int(1, 3),
                "name": random_car_name(),
            }
            for _ in range(count)
        ]
    )

    df.to_csv("../generated_cars.csv", index=False)


main()
