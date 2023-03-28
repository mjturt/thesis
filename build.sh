#!/usr/bin/env bash

source settings.sh

echo "Build model, encrypt it and generate decryption key"
cd model-trainer || exit 1
python model-trainer.py

echo "Copy encrypted model to app"
cd .. || exit 1
cp -v model-trainer/model_encrypted app/model_encrypted

echo "Build key server"
cd key-server || exit 1
make clean
make app epid

echo "Copy key server certificate to app"
cd .. || exit 1
cp -v key-server/ssl/ca.crt app/ca.crt
