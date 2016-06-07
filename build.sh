#!/bin/bash
set -x

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# This script builds an image that will be run standalone (see amalgam8/examples/controlplane/run-controlplane.sh)
make -C $SCRIPTDIR build
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo -e "\n***********\nFAILED: make failed for registry.\n***********\n"
    exit $STATUS
fi

make -C $SCRIPTDIR docker IMAGE_NAME=registry-0.1
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo -e "\n***********\nFAILED: docker build failed for registry.\n***********\n"
    exit $STATUS
fi