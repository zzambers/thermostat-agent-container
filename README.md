Thermostat Agent Builder Docker image
=============================

This repository contains Dockerfiles for a Thermostat Agent Builder image, which in turn
can be used to build a Thermostat Agent base image, call this image `icedtea/thermostat-ng-agent-centos7`.

That image, in turn, can be used for Java application images or builder images to be based on it.
By basing your image on `icedtea/thermostat-ng-agent-centos7`, a Thermostat agent can get enabled on demand in
order to monitor your Java app.

Environment variables
---------------------------------

The thermostat/thermostat-ng-agent image recognizes the following environment
variables that you can set during initialization by passing `-e VAR=VALUE` to
the Docker run command.

|    Variable name              |    Description                              |
| :---------------------------- | -----------------------------------------   |
|  `THERMOSTAT_<plugin>_URL`    | The URL for Thermostat storage              |
|  `APP_USER`                   | The application user the Java app Thermostat shall monitor runs as |

Substitute `<plugin>` for the following: `VM_GC`, `VM_MEMORY`, `HOST_OVERVIEW`, `COMMANDS`

Usage
---------------------------------
First you will need the base image that this image uses. You will need to clone and build it yourself at this time:

    $ git clone https://github.com/jerboaa/openjdk-8-maven-docker.git
    $ cd openjdk-8-maven-docker
    $ sudo docker build -t openjdk-8-64bit-maven .

Once the base image is built, you need to build this image, let's call it `icedtea/thermostat-ng-agent-builder-centos7`:

    $ sudo docker build -t icedtea/thermostat-ng-agent-builder-centos7 .

Next, build a Thermostat Agent version into `icedtea/thermostat-ng-agent-centos7` using the builder
image:

    $ sudo s2i build https://github.com/jerboaa/thermostat icedtea/thermostat-ng-agent-builder-centos7 icedtea/thermostat-ng-agent-centos7

Then, image `icedtea/thermostat-ng-agent-centos7` is intended to be used as a base image for builder/runtime images in your
Dockerfile via:

    FROM icedtea/thermostat-ng-agent-centos7
