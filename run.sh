#!/bin/bash

main() {
  if [ ! -d "/maven" ]; then
    mkdir /maven
    echo 'Downloading Maven'
    curl -O http://mirrors.gigenet.com/apache/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz

    echo 'extracting maven: '
    tar -C /maven -zxvf apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz
    rm apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz

  else
    echo 'Maven already present'
  fi

  export PATH=$PATH:/maven/apache-maven-$WERCKER_MAVEN_VERSION/bin
  mvn $WERCKER_MAVEN_COMMAND
}
main;
