#!/bin/bash

main() {

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
    curl -O https://www.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz

    curl -O https://www.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz.md5

    CHECK1=$(cat apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz.md5)
    CHECK2=$(md5sum apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz)
    CHECK1="$CHECK1  apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz"
    if [ "$CHECK1" = "$CHECK2" ] ; then
      echo "checksum matches"
    else
      echo "checksum does not match"
            exit 1
    fi

    echo 'Extracting maven '
    tar -C /maven -zxf apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz
    rm apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz*

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
