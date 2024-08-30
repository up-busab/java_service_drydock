#!/bin/bash
HERE=$(pwd)

export BUILDKIT_PROGRESS=plain

CONTEXT_IMAGE_8=local/java-build-context-8 
CONTEXT_IMAGE_13=local/java-build-context-13 
CONTEXT_IMAGE_GRAAL_22=local/java-build-context-graal-22 

init()
{
    #cd $HERE/images/java_build && docker build --build-arg BASE_MAVEN=maven:3.6.1-jdk-8-alpine -t $CONTEXT_IMAGE_8 .
    #cd $HERE/images/java_build && docker build -t $CONTEXT_IMAGE_13 .
    cd $HERE/images/java_graal_build && docker build -t $CONTEXT_IMAGE_GRAAL_22 .
}

build_app()
{
    APP_CONTEXT=$1
    APP_DEPLOYMENT=$2
    APP_DIR=$3
    APP_NAME=$4 
    APP_TAG=$5
    APP_CONFIG=$6
    
    BUILD_ARGS="--build-arg BUILD_CONTEXT_IMAGE=$APP_CONTEXT --build-arg DEPLOYMENT_IMAGE=$APP_DEPLOYMENT --build-arg APP_NAME=$APP_NAME"

    cp $APP_CONFIG $APP_DIR/src/main/resources/application-local-composition.properties
    cd $APP_DIR && docker build $BUILD_ARGS -t $APP_TAG -f $HERE/images/java_app/Dockerfile .
}

build_app_8()
{
    build_app $CONTEXT_IMAGE_8 eclipse-temurin:8-jre-alpine $1 $2 $3 $4
}

build_app_13()
{
    build_app $CONTEXT_IMAGE_13 adoptopenjdk/openjdk13:jre-13.0.2_8-alpine $1 $2 $3 $4
}

build_app_graal()
{
    build_app $CONTEXT_IMAGE_GRAAL_22 alpine:latest $1 $2 $3 $4
}

echo -e "\033[1;91mBuilding contexts\033[0m"
init

echo -e "\033[1;91mBuilding app image\033[0m"
build_app_graal $HERE/../service1 mednotes-api upbusab/service1 $HERE/config/service1.properties

#echo -e "\033[1;91mBuilding service instances\033[0m"
#build_app_13 $HERE/../service1 service1 upbusab/service2 $HERE/config/service1.properties
#build_app_13 $HERE/../service2 service2 upbusab/service2 $HERE/config/service2.properties

