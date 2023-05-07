# Key server

Intel EPID Remote Attestation capable key server. After successful remote attestation,
the key is returned.

## Requirements

- Gramine
- make, gcc

## Load settings

```sh
source ../settings.sh
```

## Build

```sh
make app epid
```

## Run

```sh
./server_epid
```

Key server now listens on localhost at port 4433.
