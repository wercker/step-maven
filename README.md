# Wercker Maven Step

A Wercker step to run Apache Maven build tasks.

This step will download and install Maven, and then execute the goals you have
requested.  You must provide your `pom.xml` and you may optionally also provide
a `settings.xml` and a `settings-security.xml`.

Downloading and installing Maven as part of the step (rather than having it
preinstalled in the box) will avoid having Maven installed in the
container/image that is built by your pipeline, this includes the `M2_HOME`
and local repository, which could result in quite a space saving, especially
if you have a lot of transitive dependencies.


## Requirements

The box must have a JDK installed in it (as Maven requires a JDK).

If you're running a box that does not have maven pre-installed, you must have `curl`, `tar`, `gzip`, and `md5sum` installed to download and install Maven.


## Usage

To use this step, include it in your `wercker.yml` pipeline. This example
assumes that the box already has Maven installed.

```
build:
  box: maven:3.5.2-jdk-8
  steps:
    - java/maven:
      goals: clean install
      settings: my-settings.xml
      profiles: prod
```


Alternatively, if you'd like to install a specific version of maven on the box
before building, simply use the following example:

```
build:
  steps:
    - java/maven:
      goals: clean install
      settings: my-settings.xml
      profiles: prod
      version: 3.5.2
```


## Parameters

All parameters are optional unless otherwise specified.

* `pom`
<br>The name of the Maven POM file to use.  If not specified, the value is assumed to be `pom.xml`.

* `settings`
<br>If you wish to provide your own `settings.xml` file, use this parameter to specify the filename of the file you wish to have Maven use as the `settings.xml`.

* `security_settings`
<br>If you wish to provide you own `settings-security.xml` file, use this parameter to specify the filename of the file you wish to have Maven use as the `settings-security.xml`.

* `goals` (required)
<br>Specify the Maven goals to execute.  This should be a space-separated list of goals (and/or phases).

* `profiles`
<br>If you wish to enable any profiles, provide a comma-separated list of profile names.

* `maven_opts`
<br>This parameter allows you to provide any settings you wish to have included in the `MAVEN_OPTS`.  For example, you may wish to specify Maven use a larger heap by specifying something like `MAVEN_OPTS="-Xmx1024m"`.

* `debug`
<br>Run Maven with the debug flags (`-X -e`) turned on.

* `version`
<br>If you would like to install Maven, specify which version you wish to use.  (Only Maven versions 3.x.x are supported).  If not specified, it is expected that Maven is already be installed. You can find a list of available versions from [https://www.apache.org/dist/maven/maven-3/](https://www.apache.org/dist/maven/maven-3/).

* `cache_repo`
<br>If set to `true` then the Maven local repository will be placed in the Wercker cache, meaning that it will still be available in subsequent builds (unless the cache is cleared) and thereby reducing the time required to download all the dependencies, plugins, etc.  The default value is currently `false` due to bug [https://github.com/wercker/wercker/issues/139](https://github.com/wercker/wercker/issues/139), but this may be changed in the future, when that bug is resolved.


## Sample Application

A sample application is provided at
[https://github.com/markxnelson/sample-maven-step](https://github.com/markxnelson/sample-maven-step)
that demonstrates how to use this step.
