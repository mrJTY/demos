#!/usr/bin/bash
# Runs test with truffle installed in node_modules
main() {
    echo "Running test with truffle in node modules (assuming its installed)"
    ./node_modules/.bin/truffle test
}

main
