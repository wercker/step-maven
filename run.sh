#!/bin/bash

# Copyright 2017, Oracle and/or its affiliates. All rights reserved.

echo "$(date +%H:%M:%S):  Hello from the Maven Wercker Step"
echo "For information on how to use this step, please review the documentation in the Wercker Marketplace,"
echo "or visit https://github.com/wercker/step-maven"

# check that all of the required parameters were provided
# note that wercker does not enforce this for us, so we have to check
if [[ -z "$WERCKER_MAVEN_GOALS" ]]; then
  fail "$(date +%H:%M:%S): All required parameters: goals MUST be specified"
fi

#
# check if a specific version of maven was requested, otherwise use the latest one we have tested with
#
if [[ -z "$WERCKER_MAVEN_VERSION" ]]; then
  WERCKER_MAVEN_VERSION="3.5.0"
fi

#
# check we have everything we need to run Maven
#

if [ -n "$JAVA_HOME" ] ; then
  if [ ! -x "$JAVA_HOME/bin/java" ] ; then
    fail "$(date +%H:%M:%S):  ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
  fi
else
  fail "$(date +%H:%M:%S):  Maven requires java to work, please ensure Java is installed and JAVA_HOME set correctly"
fi

# check that curl is installed
hash curl 2>/dev/null || { echo "$(date +%H:%M:%S):  curl is required to install maven, install curl before this step."; exit 1; }

# check that tar is installed
hash tar 2>/dev/null || { echo "$(date +%H:%M:%S):  tar is required, install tar before this step"; exit 1; }

# check that gzip is installed
hash gzip 2>/dev/null || { echo "$(date +%H:%M:%S):  gzip is required, install gzip before this step"; exit 1; }

# check that md5sum installed
hash md5sum 2>/dev/null || { echo "$(date +%H:%M:%S):  md5sum is required to validate the download, please install it before running this step"; exit 1; }

if [ ! -d "/maven" ]; then
  mkdir /maven
  echo "$(date +%H:%M:%S):  Downloading Maven"
  curl -O https://www.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz
  curl -O https://www.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz.md5

  CHECK1=$(cat apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz.md5)
  CHECK2=$(md5sum apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz)
  CHECK1="$CHECK1  apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz"
  if [ "$CHECK1" = "$CHECK2" ] ; then
    echo "$(date +%H:%M:%S):  checksum matches"
  else
    fail "$(date +%H:%M:%S):  checksum does not match"
  fi

  echo "$(date +%H:%M:%S):  Extracting maven "
  tar -C /maven -zxf apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz
  rm apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz*

else
  if [ ! -x "/maven/apache-maven-$WERCKER_MAVEN_VERSION/bin/mvn" ] ; then
      echo "$(date +%H:%M:%S):  ERROR:  maven was not installed properly"
      exit 1
  fi
  echo "$(date +%H:%M:%S):  Maven already present"
fi

export PATH=$PATH:/maven/apache-maven-$WERCKER_MAVEN_VERSION/bin

#
# prepare maven command
#

if [ "$WERCKER_MAVEN_DEBUG" = "true" ]; then
  DEBUG="-X -e"
else
  DEBUG=""
fi

if [[ -z "$WERCKER_MAVEN_PROFILES" ]]; then
  PROFILES=""
else
  PROFILES="-p $WERCKER_MAVEN_PROFILES"
fi

if [[ -z "$WERCKER_MAVEN_MAVEN_OPTS" ]]; then
  MAVEN_OPTS=""
else
  MAVEN_OPTS="-p $WERCKER_MAVEN_MAVEN_OPTS"
fi

if [[ -z "$WERCKER_MAVEN_SETTINGS" ]]; then
  SETTINGS=""
else
  SETTINGS="-s $WERCKER_MAVEN_SETTINGS"
fi

# set the M2_HOME
# put security-settings.xml in the right place
export M2_HOME="/maven/apache-maven-$WERCKER_MAVEN_VERSION"
export MAVEN_OPTS="$WERCKER_MAVEN_MAVEN_OPTS"

if [[ -z "$WERCKER_MAVEN_SECURITY_SETTINGS" ]]; then
  # do nothing
  echo "" > /dev/null
else
  cp $WERCKER_MAVEN_SECURITY_SETTINGS $M2_HOME/
fi

# put the local repository into the Wercker Cache directory, so that it
# would still be available on subsequent runs (unless cache is cleared)
# keeping this optional because of bug https://github.com/wercker/wercker/issues/139
if [ "$WERCKER_MAVEN_CACHE_REPO" = "true" ]; then
  CACHE_REPO=""
else
  CAHCE_REPO="-Dmaven.repo.local=$WERCKER_CACHE_DIR/.m2"
fi

#
# run the maven command
#
mvn $CACHE_REPO $DEBUG $SETTINGS $PROFILES $MAVEN_OPTS $WERCKER_MAVEN_GOALS


