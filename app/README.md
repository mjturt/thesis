# App

Requirements:

- Gramine with Intel SGX and EPID remote attestation support
- python3-sklearn
- python3-joblib (1.1.0)
- python3-cryptography

Load settings:

```sh
source ../settings.sh
```

Build:

```sh
make SGX=1
```

```sh
gramine-sgx python app.py
```
