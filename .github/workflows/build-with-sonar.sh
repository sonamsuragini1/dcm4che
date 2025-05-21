#!/bin/bash

set -e

# Navigate to the repo root (optional safety check)
cd "$(git rev-parse --show-toplevel)"

# Build only dcm4che-core and its dependencies
mvn -B -pl dcm4che-core --also-make clean verify -DskipTests

if [ -z "$SONAR_TOKEN" ]
then
  echo "Cannot run sonar analysis as there is no SONAR_TOKEN. \
  This happens for external pull requests (from forks). See https://jira.sonarsource.com/browse/MMF-1371"
else
  # Run sonar ONLY in dcm4che-core
  pushd dcm4che-core
  mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
    -Dsonar.projectKey=dcm4che-core \
    -Dsonar.sources=src/main/java \
    -Dsonar.tests=src/test/java \
    -Dsonar.java.binaries=target/classes \
    -Dsonar.projectBaseDir=$(pwd) \
    -Dsonar.coverage.jacoco.xmlReportPaths=$(find "$(pwd)" -path '*/target/site/*/jacoco.xml' | tr '\n' ',') \
    -Dsonar.login=$SONAR_TOKEN
  popd
fi
