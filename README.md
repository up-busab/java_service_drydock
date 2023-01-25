Java Service Template

config contains properties files for all services defined in docker-compose.yml

to override maven settings and jar's in build containers-
1. copy you settings.xml and settings-security.xml from your local m2 into images/java_build/m2_override 
2. change settings.xml so it has <localRepository>/root/.m2/repository</localRepository>
3. place any override JARs in images/java_build/m2_override 

for additional services you want to containerize-
1. edit build.sh and docker-compose.yml to include required services
2. run build.sh from this folder
3. run composition: docker compose up
  
