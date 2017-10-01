# Wercker Maven Step
A Wercker step to run Apache Maven build tasks.

This step will download and install Maven, and then execute the goals you have requested.  You must provide your `pom.xml` and you may optionally also provide a `settings.xml` and a `settings-security.xml`.

Downloading and installing Maven as part of the step (rather than having it preinstalled in the box) will avoid having Maven installed in the container/image that is built by your pipeline, this includes the `M2_HOME` and local repository, which could result in quite a space saving, especially if you have a lot of transitive dependencies.
 

## Requirements

The box that you run this step in must either have `curl`, `tar`, `gzip`, and `md5sum` installed in it, or it must have Maven already installed in `/maven`.  It is preferred that Maven is not pre-installed, in order to keep the image size a small as possible.

Additionally, it must have a JDK installed in it (as Maven requires a JDK).


## Usage

To use this step, include it in your `wercker.yml` pipeline, for example:


```
build:
  steps:
    - java/maven:
      goals: clean install 
      settings: my-settings.xml
      profiles: prod
```

After the Maven step has completed, you will need to either push your image to a repostiory, or copy any built artifacts that you want to pass to the next pipeline into the `/pipeline/output` directory.  Anything that you do not copy into that directory will be lost. 

To push your image, use the `internal/docker-push` step, for example:

```
    - internal/docker-push:
        username: $QUAY_IO_USERNAME
        password: $QUAY_IO_PASSWORD
        repository: quay.io/myuser/myapp
        tag: 1.0.0
```

To pass artifacts to the next pipeline:

```        
    - script:
      code: | 
        cp target/my-awesome-application.jar /pipeline/output
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
<br>Specify the version of Maven that you wish to use.  (Only Maven versions 3.x.x are supported).  If not specified, this will default to `3.5.0`.

* `cache_repo`
<br>If set to `true` then the Maven local repository will be placed in the Wercker cache, meaning that it will still be available in subsequent builds (unless the cache is cleared) and thereby reducing the time required to donwload all the dependencies, plugins, etc.  The default value is currently `false` due to bug [https://github.com/wercker/wercker/issues/139](https://github.com/wercker/wercker/issues/139), but this may be changed in the future, when that bug is resolved.

## Sample Application

A sample application is provided at [https://github.com/markxnelson/sample-maven-step](https://github.com/markxnelson/sample-maven-step) that demonstrates how to use this step. 
