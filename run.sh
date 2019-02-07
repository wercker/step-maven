#!/bin/bash

# Copyright 2017, 2018, Oracle and/or its affiliates. All rights reserved.

function url_exists()
{
    local _url=$1
    if curl --output /dev/null --silent --head --fail "$_url"; then
        return 0
    else
        return 1
    fi
}

debug "$(date +%H:%M:%S):  Hello from the Maven Wercker Step"
info "For information on how to use this step, please review the documentation "
info "in the Wercker Marketplace, or visit https://github.com/wercker/step-maven"

# check that all of the required parameters were provided
# note that wercker does not enforce this for us, so we have to check
if [[ -z "$WERCKER_MAVEN_GOALS" ]]; then
  fail "$(date +%H:%M:%S): All required parameters: goals MUST be specified"
fi

# check java is installed
if [ -n "$JAVA_HOME" ] ; then
  if [ ! -x "$JAVA_HOME/bin/java" ] ; then
    fail "$(date +%H:%M:%S):  ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
  fi
else
  fail "$(date +%H:%M:%S):  Maven requires java to work, please ensure Java is installed and JAVA_HOME set correctly"
fi

# if a specific version of Maven was requested, attempt to install it
if [[ ! -z "$WERCKER_MAVEN_VERSION" ]]; then
  # check that curl is installed
  hash curl 2>/dev/null || { fail "$(date +%H:%M:%S):  curl is required to install Maven, install curl before this step."; }

  # check that tar is installed
  hash tar 2>/dev/null || { fail "$(date +%H:%M:%S):  tar is required, install tar before this step"; }

  # check that gzip is installed
  hash gzip 2>/dev/null || { fail "$(date +%H:%M:%S):  gzip is required, install gzip before this step"; }

  # check that sha1sum installed
  hash sha1sum 2>/dev/null || { fail "$(date +%H:%M:%S):  sha1sum is required to validate the download, please install it before running this step"; }

  # check that sha256sum installed
  hash sha256sum 2>/dev/null || { fail "$(date +%H:%M:%S):  sha256sum is required to validate the download, please install it before running this step"; }

  # check that sha512sum installed
  hash sha512sum 2>/dev/null || { fail "$(date +%H:%M:%S):  sha512sum is required to validate the download, please install it before running this step"; }

  # check that procps is installed
  hash ps 2>/dev/null || { fail "$(date +%H:%M:%S):  The procps package is required for surefire test execution, install procps before this step"; }

  if [ ! -d "/maven" ]; then
    mkdir /maven
  fi

  _maven_dist_url="https://archive.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz"

  checksum=
  checksum=
  if url_exists "${_maven_dist_url}.sha512" ; then
      checksum=sha512
  elif url_exists "${_maven_dist_url}.sha256" ; then
      checksum=sha256
  elif url_exists "${_maven_dist_url}.sha1" ; then
      checksum=sha1
  else
      echo "Cannot find maven distribution checksum file ${_maven_dist_url}.[sha512|sha251|sha1]"
      exit 1
  fi

  curl -s -O https://archive.apache.org/dist/maven/maven-3/$WERCKER_MAVEN_VERSION/binaries/apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz.${checksum}

  debug "$(date +%H:%M:%S):  Downloading Maven"
  curl -# -O "$_maven_dist_url"

  checksum_cmd="${checksum}sum"
  CHECK1=$(cat apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz.$checksum | cut -d' ' -f1)
  CHECK2=$($checksum_cmd apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz)
  CHECK1="$CHECK1  apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz"
  if [ "$CHECK1" = "$CHECK2" ] ; then
    debug "$(date +%H:%M:%S):  checksum matches"
  else
    fail "$(date +%H:%M:%S):  checksum does not match"
  fi

  debug "$(date +%H:%M:%S):  Extracting Maven "
  tar -C /maven -zxf apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz
  rm apache-maven-$WERCKER_MAVEN_VERSION-bin.tar.gz*

  # add maven to $PATH
  export PATH=$PATH:/maven/apache-maven-$WERCKER_MAVEN_VERSION/bin
fi

# At this point, Maven should be installed
hash mvn 2>/dev/null || { fail "$(date +%H:%M:%S):  Maven is not installed and no version was specified."; }

#
# prepare Maven command
#

if [ "$WERCKER_MAVEN_DEBUG" = "true" ]; then
  DEBUG="-X -e"
else
  DEBUG=""
fi

if [[ -z "$WERCKER_MAVEN_PROFILES" ]]; then
  PROFILES=""
else
  PROFILES="-P $WERCKER_MAVEN_PROFILES"
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

if [[ -z "$WERCKER_MAVEN_POM" ]]; then
  POM=""
else
  POM="-f $WERCKER_MAVEN_POM"
fi

# Set the M2_HOME
# Put security-settings.xml in the right place
export M2_HOME="/maven/apache-maven-$WERCKER_MAVEN_VERSION"
export MAVEN_OPTS="$WERCKER_MAVEN_MAVEN_OPTS"

if [[ ! -z "$WERCKER_MAVEN_SECURITY_SETTINGS" ]]; then
  cp $WERCKER_MAVEN_SECURITY_SETTINGS $M2_HOME/
fi

# Put the local repository into the Wercker Cache directory, so that it
# would still be available on subsequent runs (unless cache is cleared)
# keeping this optional because of bug https://github.com/wercker/wercker/issues/139
if [ "$WERCKER_MAVEN_CACHE_REPO" = "true" ]; then
  debug "$(date +%H:%M:%S): using cache repository at $WERCKER_CACHE_DIR/.m2"
  MAVEN_OPTS="$MAVEN_OPTS -Dmaven.repo.local=$WERCKER_CACHE_DIR/.m2"
fi

CMD="mvn $DEBUG $SETTINGS $PROFILES $MAVEN_OPTS $POM $WERCKER_MAVEN_GOALS"
# Run the Maven command
if [[ -z "$WERCKER_MAVEN_SUDO_USER" ]]; then 
  $CMD
else
  hash sudo 2>/dev/null || { fail "$(date +%H:%M:%S):  sudo must be installed if you specify sudo_user, install sudo before this step"; }
  chown -R $WERCKER_MAVEN_SUDO_USER $WERCKER_ROOT
  chown -R $WERCKER_MAVEN_SUDO_USER $M2_HOME
  chown -R $WERCKER_MAVEN_SUDO_USER $WERCKER_CACHE_DIR
  XCMD="cd $WERCKER_ROOT; PATH=$PATH M2_HOME=$M2_HOME $CMD"
  /usr/bin/sudo -i -u $WERCKER_MAVEN_SUDO_USER -- bash -c "$XCMD"
fi
