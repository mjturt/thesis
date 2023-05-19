#!/usr/bin/env bash

cd model-trainer || exit 1
make clean

cd ..
cd key-server || exit 1
make clean

cd ..
cd predictor/trusted || exit 1
make clean
