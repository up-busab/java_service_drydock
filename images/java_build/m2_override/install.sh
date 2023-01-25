#!/bin/sh

for f in /usr/local/tmp_m2_override/*.jar; do 
  [[ -f "$f" ]] || continue
  echo "---installing override jar $f"
  mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file -Dfile=$f
done
