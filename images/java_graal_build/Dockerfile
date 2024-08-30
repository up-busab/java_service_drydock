ARG BASE_GRAAL_NATIVE_IMAGE=container-registry.oracle.com/graalvm/native-image:22

FROM $BASE_GRAAL_NATIVE_IMAGE 

RUN microdnf install maven -y

#use provided settings
RUN mkdir -p /root/.m2/repository
COPY m2_override/*.xml /root/.m2

#mvn install any JARs we want to override with
RUN mkdir /usr/local/tmp_m2_override
COPY m2_override/*.jar  /usr/local/tmp_m2_override
COPY m2_override/install.sh  /usr/local/tmp_m2_override
RUN --mount=type=cache,target=/root/.m2/repository /usr/local/tmp_m2_override/install.sh

#entry scripts
RUN mkdir -p /build_context
COPY run_dev.sh /build_context 
COPY run_prod.sh /build_context 

#ENTRYPOINT ["tail", "-f", "/dev/null"]
