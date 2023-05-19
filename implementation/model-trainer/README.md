# Model trainer

Python application that trains model, encrypts it and exports key for key-server.

Dataset contains instances of cars with multiple parameters. Model is trained so that
it can predict fuel consumption based on other parameters.

Dataset origin: <https://archive.ics.uci.edu/ml/datasets/auto+mpg>

## Requirements

- python3-sklearn
- python3-joblib (1.1.0)
- python3-cryptography
- python3-pandas

## Run

```sh
python model-trainer.py
```

## Synthetic data

Synthetic data CSV (`../generated_data.csv`) can be generated with `python data-generator.py <row count>`.
