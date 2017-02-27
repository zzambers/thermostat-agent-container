FROM centos/s2i-base-centos7
# Thermostat Agent Image.
#
# Environment:
#  * $THERMOSTAT_AGENT_USERNAME - User name for the thermostat agent to use
#                                 for connecting to storage.
#  * $THERMOSTAT_AGENT_PASSWORD - Password for the thermostat agent to use
#                                 for connecting to storage.
#  * $THERMOSTAT_DB_URL         - The storage URL to connect to.
#  * $APP_USER                  - The application user the Java app Thermostat
#                                 shall monitor runs as.

ENV THERMOSTAT_VERSION=HEAD \
    APP_USER="default"

LABEL io.k8s.description="A monitoring and serviceability tool for OpenJDK." \
      io.k8s.display-name="Thermostat Agent"

ENV THERMOSTAT_CMDC_PORT 12000
ENV THERMOSTAT_HOME /opt/app-root/thermostat
ENV USER_THERMOSTAT_HOME /opt/app-root/.thermostat

EXPOSE ${THERMOSTAT_CMDC_PORT}

# Install s2i build scripts
COPY ./s2i/bin/ ${STI_SCRIPTS_PATH}

# Ensure THERMOSTAT_HOME (and parents) exist
RUN mkdir -p ${THERMOSTAT_HOME}

RUN yum install -y centos-release-scl-rh && \
    yum-config-manager --enable centos-sclo-rh-testing && \
    yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus \
    nss_wrapper rh-maven33 libsecret-devel make \
    gcc gtk2-devel autoconf automake libtool && \
    yum erase -y java-1.8.0-openjdk-headless && \
    yum clean all -y
COPY thermostat-user-home-config ${USER_THERMOSTAT_HOME}
COPY contrib /opt/app-root

# Ensure any UID can read/write to files in /opt/app-root
RUN chown -R default:0 /opt/app-root && \
    find /opt/app-root -type d -exec chmod g+rwx '{}' \; && \
    find /opt/app-root -type f -exec chmod g+rw '{}' \;

WORKDIR ${HOME}

ADD bin /usr/bin
ADD container-scripts /usr/share/container-scripts

# Remove any potential Hotspot perf data files
RUN rm -rf /tmp/hsperfdata_*

USER 1001

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/thermostat \
    ENABLED_COLLECTIONS=rh-maven33

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    PROMPT_COMMAND=". ${CONTAINER_SCRIPTS_PATH}/scl_enable"

ENTRYPOINT ["container-entrypoint"]
CMD [ "run-thermostat-agent" ]
