#!/usr/bin/env bash

source settings.sh

echo "Build model, encrypt it and generate decryption key"
cd model-trainer || exit 1
python model-trainer.py

echo "Copy encrypted model to predictor"
cd .. || exit 1
cp -v model-trainer/model_encrypted predictor/trusted/model_encrypted
echo "Copy test dataset to predictor"
cp -v model-trainer/data/cars2.csv predictor/trusted/cars.csv

echo "Build key server"
cd key-server || exit 1
make clean
make app epid

echo "Copy key server certificate to predicotr"
cd .. || exit 1
cp -v key-server/ssl/ca.crt predictor/trusted/ca.crt

echo "--- NEXT STEPS ---"
echo
echo "source settings.sh"
echo "cd key-server"
echo "./server_epid"
echo
echo "In other terminal:"
echo
echo "source settings.sh"
echo "cd predictor/trusted"
echo "make SGX=1"
echo "cd .."
echo "python predictor.py"
