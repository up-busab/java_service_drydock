ARG ALPINE_JDK_IMAGE=container-registry.oracle.com/graalvm/native-image:22

FROM $ALPINE_JDK_IMAGE 
ARG M2_OVERRIDE=m2_override/none
ARG TMP_M2=/build_context/tmp_m2
ARG LOCAL_M2=/root/.m2
ARG PYTHON_REQS=""

WORKDIR /build_context

RUN microdnf install maven python3 python3-pip -y || apk add maven python3 py3-pip
COPY scripts/*.sh /build_context 

RUN echo ${PYTHON_REQS} | tr ';' '\n' > requirements.txt
RUN rm -rf /usr/lib/python*/EXTERNALLY-MANAGED
RUN pip install -r requirements.txt

RUN mkdir -p ${LOCAL_M2}/repository && mkdir ${TMP_M2}
COPY ${M2_OVERRIDE}/*.xml ${LOCAL_M2}
COPY ${M2_OVERRIDE}/repository/* ${LOCAL_M2}
COPY ${M2_OVERRIDE}/*.jar ${TMP_M2}
RUN --mount=type=cache,target=${LOCAL_M2}/repository /build_context/m2_jar_installer.sh ${TMP_M2} ${LOCAL_M2}/repository
