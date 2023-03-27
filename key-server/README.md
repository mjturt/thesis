# Key server

Requirements:

- Gramine
- make, gcc, etc.

Load settings:

```sh
source ../settings.sh
```

Build:

```sh
make app epid
```

Run:

```sh
./server_epid
```

Key server now listens on localhost at port 4433.
