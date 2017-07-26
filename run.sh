#!/bin/bash

main() {
  if [ -n "$JAVA_HOME" ] ; then
    if [ ! -x "$JAVAHOME/bin/java" ] ; then
        echo "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
        exit 1
    fi
  else
    echo 'Maven requires java to work, please ensure Java is installed and JAVA_HOME set correctly'
    exit 1
  fi

  if command -v curl ; then
    echo "curl is required to fetch maven please install it before this step."
    exit 1
  fi
  if command -v tar ; then
    echo "tar is required to fetch maven please install it before this step."
    exit 1
  fi

  if [ ! -d "/maven" ]; then
    mkdir /maven
    echo 'Downloading Maven'
    curl -O http://mirrors.gigenet.com/apache/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz

    echo 'extracting maven: '
    tar -C /maven -zxvf apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz
    rm apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz

  else
    if [ ! -x "/maven/apache-maven-$WERCKER_MAVEN_VERSION/bin/mvn" ] ; then
        echo "ERROR:  maven was not installed properly"
        exit 1
    fi
    echo 'Maven already present'
  fi

  export PATH=$PATH:/maven/apache-maven-$WERCKER_MAVEN_VERSION/bin
  mvn $WERCKER_MAVEN_COMMAND
}
main;
