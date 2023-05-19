# Car consumption prediction application

Python application that predicts car fuel consumption based on other parameters.
All model handling and ML calculations happens inside Intel SGX enclave.

The application has two parts: the main application `predictor.py` and the Gramine
application that runs inside Intel SGX enclave.

The model is encrypted and after a successfull remote attestation the key-server
returns decryption key.

## Requirements

- Gramine with Intel SGX and EPID remote attestation support
- python3-sklearn
- python3-joblib (1.1.0)
- python3-cryptography
- python3-pandas

## Load settings

```sh
source ../settings.sh
```

## Build

```sh
cd trusted
make SGX=1
```

## Run

To get available options:

```sh
cd ..
python predictor.py --help
```

The Gramine application can also be run directly from the `trusted/` directory:

```sh
gramine-sgx python trusted.py
```

## Testing

`predictor.py` can be run with `--nosgx` parameter to disable Intel SGX:

```sh
python predictor.py --nosgx
```

When using `--nosgx` argument, the files `model_encrypted` and `cars2.csv` must be
in the root of filesystem (`/model_encrypted` and `/cars2.csv`) as the isolated environment
expects them there.
