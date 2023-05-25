#!/usr/bin/env bash

main() {
    echo "Running tests with bazel test... (if this fails, use ./bin/truffle-test)"
    bazel run test
}

main
