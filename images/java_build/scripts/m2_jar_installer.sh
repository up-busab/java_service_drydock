#!/bin/sh

for f in $1/*.jar; do 
  [[ -f "$f" ]] || continue
  echo "---installing jar $f"
  mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file -Dfile=$f -Dmaven.repo.local=$2
done

cp -rf /lib_builder/src/main/java/com/upbusab/bureau/domain/* /lib_builder/m2/repository || exit 0

