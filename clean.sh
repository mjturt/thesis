#!/usr/bin/env bash

cd model-trainer || exit 1
make clean

cd key-server || exit 1
make clean

cd app || exit 1
make clean
