#!/bin/bash
HERE=$(pwd)

source $HERE/contexts.sh

echo -e "\033[1;91mBuilding app image\033[0m"
build_app_graal $HERE/../service1 service1 upbusab/service1 $HERE/config/service1.properties

