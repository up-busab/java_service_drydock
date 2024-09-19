#!/bin/bash
JSD_PATH=${JSD_PATH:-$(pwd)}
PROJECT_PATH=${PROJECT_PATH:-$JSD_PATH}
IMAGE_PATH=$JSD_PATH/images

init()
{
    JSD_CONFIG=$1

    eval $(parse_yaml $JSD_PATH/config.yml)   
    if [ ! -z "$JSD_CONFIG" ]; then
        eval $(parse_yaml $JSD_CONFIG)
    fi

    BUILD_ARGS="--build-arg PYTHON_REQS=$JSD_PYTHON_REQS"
    cd $IMAGE_PATH/java_build && docker build $BUILD_ARGS -t $JSD_CONTEXT_IMAGE_22 . || exit 1
    
    BUILD_ARGS="$BUILD_ARGS --build-arg ALPINE_JDK_IMAGE=$JSD_ALPINE_JDK"
    cd $IMAGE_PATH/java_build && docker build $BUILD_ARGS -t $JSD_CONTEXT_IMAGE_GRAAL_22 . || exit 1
}

build_lib()
{
    local LIB_CONTEXT=$1
    local LIB_DIR=$2
    local LIB_NAME=$3
    
    local BUILD_ARGS=""
    BUILD_ARGS="$BUILD_ARGS --build-arg BUILD_CONTEXT_IMAGE=$LIB_CONTEXT"
    BUILD_ARGS="$BUILD_ARGS --build-arg LIB_NAME=$LIB_NAME" 
    BUILD_ARGS="$BUILD_ARGS --build-arg M2_OVERRIDE=$JSD_M2_OVERIDE"

    local DOCKERFILE=$IMAGE_PATH/java_lib/Dockerfile

    cd $LIB_DIR && docker build $BUILD_ARGS -t $JSD_LIB_BUILDER_TAG -f $DOCKERFILE . || exit 1
    docker run -it -v $PROJECT_PATH/$JSD_M2_TARGET:$JSD_LIB_BUILDER_INTERNAL_M2 $JSD_LIB_BUILDER_TAG
}

build_lib_graal()
{
    build_lib $CONTEXT_IMAGE_GRAAL_22 $1 $2 
}

build_lib_22()
{
    build_lib $JSD_CONTEXT_IMAGE_22 $1 $2 
}

build_app()
{
    local APP_CONTEXT=$1
    local APP_DEPLOYMENT=$2
    local APP_DIR=$3
    local APP_NAME=$4 
    local APP_TAG=$5
    local APP_CONFIG=$6
    
    local BUILD_ARGS=""
    local BUILD_ARGS="$BUILD_ARGS --build-arg BUILD_CONTEXT_IMAGE=$APP_CONTEXT" 
    local BUILD_ARGS="$BUILD_ARGS --build-arg DEPLOYMENT_IMAGE=$APP_DEPLOYMENT" 
    local BUILD_ARGS="$BUILD_ARGS --build-arg APP_NAME=$APP_NAME"

    setup_config $APP_DIR $APP_CONFIG

    cd $APP_DIR && docker build $BUILD_ARGS -t $APP_TAG -f $IMAGE_PATH/java_app/Dockerfile .
}

build_app_8()
{
    build_app $JSD_CONTEXT_IMAGE_8 $JSD_ALPINE_RUNTIME_8 $1 $2 $3 $4
}

build_app_graal()
{
    build_app $JSD_CONTEXT_IMAGE_GRAAL_22 $JSD_ALPINE_RUNTIME $1 $2 $3 $4
}

setup_config()
{
    local APP_DIR=$1
    local APP_CONFIG=$2

    local APP_PROPS="$APP_DIR/$JSD_PROPS_LOCATION"

    if [ ! -z "$APP_CONFIG" ]; then
        cp $APP_CONFIG $APP_PROPS 
    else
        touch $APP_PROPS
    fi
}

parse_yaml() 
{
   local filename=$1
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $filename |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
