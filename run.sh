#!/bin/bash

# Copyright 2017, Oracle and/or its affiliates. All rights reserved.

echo "$(date +%H:%M:%S):  Hello from the Maven Wercker Step"
echo "For information on how to use this step, please review the documentation in the Wercker Marketplace,"
echo "or visit https://github.com/wercker/maven-step"

# check that all of the required parameters were provided
# note that wercker does not enforce this for us, so we have to check
if [[ -z "$WERCKER_MAVEN_STEP_GOALS" ]]; then
  echo "$(date +%H:%M:%S): All required parameters: goals MUST be specified"
  exit 9
fi

#
# check if a specific version of maven was requested, otherwise use the latest one we have tested with
#
if [[ -z "$WERCKER_MAVEN_STEP_VERSION" ]]; then
  WERCKER_MAVEN_STEP_VERSION="3.5.0"
fi


#
# check we have everything we need to run Maven
#

if [ -n "$JAVA_HOME" ] ; then
  if [ ! -x "$JAVA_HOME/bin/java" ] ; then
    echo "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
    exit 1
  fi
else
  echo 'Maven requires java to work, please ensure Java is installed and JAVA_HOME set correctly'
  exit 1
fi

if [ hash curl 2>/dev/null ] ; then
  echo 'curl is required to install maven, install curl before this step.'
  exit 1
fi

if [ hash tar 2>/dev/null ] ; then
  echo 'tar is required, install tar before this step'
  exit 1
fi

if [ hash md5sum 2>/dev/null ] ; then
  echo 'md5sum is required to validate the download, please install it before running this step'
  exit 1
fi

if [ ! -d "/maven" ]; then
  mkdir /maven
  echo 'Downloading Maven'
  curl -O https://www.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_STEP_VERSION/binaries/apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz
  curl -O https://www.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_STEP_VERSION/binaries/apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz.md5

  CHECK1=$(cat apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz.md5)
  CHECK2=$(md5sum apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz)
  CHECK1="$CHECK1  apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz"
  if [ "$CHECK1" = "$CHECK2" ] ; then
    echo "checksum matches"
  else
    echo "checksum does not match"
    exit 1
  fi

  echo 'Extracting maven '
  tar -C /maven -zxf apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz
  rm apache-maven-$WERCKER_MAVEN_STEP_VERSION-bin.tar.gz*

else
  if [ ! -x "/maven/apache-maven-$WERCKER_MAVEN_STEP_VERSION/bin/mvn" ] ; then
      echo "ERROR:  maven was not installed properly"
      exit 1
  fi
  echo 'Maven already present'
fi

export PATH=$PATH:/maven/apache-maven-$WERCKER_MAVEN_STEP_VERSION/bin

#
# prepare maven command
#

if [ "$WERCKER_MAVEN_STEP_DEBUG" = "true" ]; then
  DEBUG="-X -e"
else
  DEBUG=""
fi

if [[ -z "$WERCKER_MAVEN_STEP_PROFILES" ]]; then
  PROFILES=""
else
  PROFILES="-p $WERCKER_MAVEN_STEP_PROFILES"
fi

if [[ -z "$WERCKER_MAVEN_STEP_MAVEN_OPTS" ]]; then
  MAVEN_OPTS=""
else
  MAVEN_OPTS="-p $WERCKER_MAVEN_STEP_MAVEN_OPTS"
fi

if [[ -z "$WERCKER_MAVEN_STEP_SETTINGS" ]]; then
  SETTINGS=""
else
  SETTINGS="-s $WERCKER_MAVEN_STEP_SETTINGS"
fi

# set the M2_HOME
# put security-settings.xml in the right place
export M2_HOME="/maven/apache-maven-$WERCKER_MAVEN_STEP_VERSION"

if [[ -z "$WERCKER_MAVEN_STEP_SECURITY_SETTINGS" ]]; then
  // do nothing
else
  cp $WERCKER_MAVEN_STEP_SECURITY_SETTINGS $M2_HOME/
fi

#
# run the maven command
#
mvn $DEBUG $SETTINGS $PROFILES $MAVEN_OPTS $WERCKER_MAVEN_STEP_GOALS


