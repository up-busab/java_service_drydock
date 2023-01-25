ARG BUILD_CONTEXT_IMAGE
ARG DEPLOYMENT_IMAGE=adoptopenjdk/openjdk13:jre-13.0.2_8-alpine
ARG BUILD_MODE=dev
ARG APP_NAME=your-artifactId-from-pom

#base layer sets up local m2 and adds source
FROM $BUILD_CONTEXT_IMAGE as base_build
ARG APP_NAME
WORKDIR /app_build

#bring in the source and overwrite properties
COPY pom.xml .
COPY src ./src
RUN mv ./src/main/resources/application-local-composition.properties ./src/main/resources/application.properties 


#now build a deployment
#different layers for dev,test,prod- one is selected as intermediate
RUN mkdir deploy


#developement build
FROM base_build as dev_build
RUN --mount=type=cache,target=/root/.m2/repository mvn package -DskipTests
RUN mv target/${APP_NAME}.jar deploy/app.jar 
COPY --from=base_build /build_context/run_dev.sh deploy/entry.sh


#test build- incomplete
FROM base_build as test_build
RUN echo "Test build not implemented."


#prod build- incomplete
FROM base_build as prod_build
#see https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3
#requires spring-boot-maven-plugin to have only <configuration> of <layers><enabled>true</enabled></layers> 
RUN mvn package -DskipTests
RUN java -Djarmode=layertools -jar target/${APP_NAME}.jar extract --destination deploy
COPY --from=base_build /build_context/run_prod.sh deploy/entry.sh


#finally, select build and create deplayment
FROM ${BUILD_MODE}_build as intermediate

#run deployment on a JRE image
FROM $DEPLOYMENT_IMAGE as final
WORKDIR /app

COPY --from=intermediate /app_build/deploy/* .

RUN addgroup --system javauser && adduser -S -s /bin/false -G javauser javauser
RUN chown -R javauser:javauser /app
USER javauser

#EXPOSE 8080
ENTRYPOINT /app/entry.sh
