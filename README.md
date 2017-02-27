Thermostat Agent Docker image
=============================

This repository contains Dockerfiles for a Thermostat Agent Builder image, which in turn
can be used to build a Thermostat Agent base image, call this image `thermostat/thermostat-agent`.

That image, in turn, can be used for Java application images or builder images to be based on it.
By basing your image on `thermostat/thermostat-agent`, a Thermostat agent can get enabled on demand in
order to monitor your Java app.

Environment variables
---------------------------------

The thermostat/thermostat-agent image recognizes the following environment
variables that you can set during initialization by passing `-e VAR=VALUE` to
the Docker run command.

|    Variable name              |    Description                              |
| :---------------------------- | -----------------------------------------   |
|  `THERMOSTAT_AGENT_USERNAME`  | User name for the Thermostat agent to use connecting to storage |
|  `THERMOSTAT_AGENT_PASSWORD`  | Password for connecting to storage          |
|  `THERMOSTAT_DB_URL`          | The URL for Thermostat storage              |
|  `APP_USER`                   | The application user the Java app Thermostat shall monitor runs as |


Usage
---------------------------------

First you need to build this image, let's call it `thermostat/thermostat-agent-builder`:

    $ sudo docker build -t thermostat/thermostat-agent-builder .

Next, build a Thermostat Agent version into `thermostat/thermostat-agent` using the builder
image:

    $ sudo s2i build https://github.com/jerboaa/thermostat thermostat/thermostat-agent-builder thermostat/thermostat-agent

Then, image `thermostat/thermostat-agent` is intended to be used as a base image for builder/runtime images in your
Dockerfile via:

    FROM thermostat/thermostat-agent

For example, a complete drop-in replacement Dockerfile for the `openshift/wildfly-101-centos7`
image which will have the Thermostat agent pre-installed has been illustrated here:

https://github.com/jerboaa/thermostat-agent-container-ex

Once the `thermostat/thermostat-agent` image has been introduced into the image
hierarchy the Thermostat agent can be started by setting the three required Thermostat
environment variables. Let's consider image `thermostat/thermostat-wildfly-test` which uses
`thermostat/thermostat-agent` as its base image and runs Java app `foo` on deployment,
then a Thermostat agent can be started together with `foo` by setting the following
environment variables:

    THERMOSTAT_AGENT_USERNAME
    THERMOSTAT_AGENT_PASSWORD
    THERMOSTAT_DB_URL

Image `thermostat/thermostat-storage` can be used to set up a storage endpoint for the
agent to connect to.
