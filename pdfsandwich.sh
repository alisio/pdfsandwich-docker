#!/bin/bash

docker run --rm -v "$(pwd):/data" pdfsandwich-docker "$@"
