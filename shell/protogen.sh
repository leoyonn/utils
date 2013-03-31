#!/bin/sh
# Executable protoc is only compiled and tested on nb cluster
./bin/protoc -I ./src --java_out=./src/java ./src/protobuf/silmaril.proto
