#!/bin/bash

exec cpp -P -traditional-cpp -nostdinc -undef "$@"
