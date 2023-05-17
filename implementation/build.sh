#!/usr/bin/env bash

source settings.sh

echo "Build model, encrypt it and generate decryption key"
cd model-trainer || exit 1
python model-trainer.py

echo "Copy encrypted model to app"
cd .. || exit 1
cp -v model-trainer/model_encrypted app/trusted/model_encrypted
echo "Copy test dataset to app"
cp -v model-trainer/data/cars2.csv app/trusted/cars.csv

echo "Build key server"
cd key-server || exit 1
make clean
make app epid

echo "Copy key server certificate to app"
cd .. || exit 1
cp -v key-server/ssl/ca.crt app/trusted/ca.crt

echo "--- NEXT STEPS ---"
echo
echo "source settings.sh"
echo "cd key-server"
echo "./server_epid"
echo
echo "In other terminal:"
echo
echo "source settings.sh"
echo "cd app/trusted"
echo "make SGX=1"
echo "cd .."
echo "python app.py"
