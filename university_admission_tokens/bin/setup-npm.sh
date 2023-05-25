#!/usr/bin/bash
set -e

main() {
    echo "Checking if you have all the dependencies installed..."
    echo "Checking node..."
    hash node
    hash npm
    echo "Node and NPM ok."

    echo "Checking bazel..."
    hash bazel
    echo "bazel ok"

    echo "Checking truffle..."
    hash truffle
    echo "truffle ok"

    echo "All dependencies installed, now run ./bin/test.sh"

}

main
