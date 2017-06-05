FROM openjdk-8-64bit-maven

# Thermostat Agent Builder Image.
#
# Environment:
#  * $THERMOSTAT_JVM_GC_URL           - The URL to the jvm-gc microservice.
#  * $THERMOSTAT_JVM_MEMORY_URL       - The URL to the jvm-memory microservice.
#  * $APP_USER                        - The application user the Java app Thermostat
#                                       shall monitor runs as.
ENV THERMOSTAT_VERSION=HEAD \
    APP_USER="default"

LABEL io.k8s.description="A monitoring and serviceability tool for OpenJDK." \
      io.k8s.display-name="Thermostat Agent"

ENV THERMOSTAT_HOME /opt/app-root/thermostat
ENV USER_THERMOSTAT_HOME /opt/app-root/.thermostat

USER root

# Ensure THERMOSTAT_HOME (and parents) exist
RUN mkdir -p ${THERMOSTAT_HOME}

# Install required RPMs and ensure that the packages were installed
RUN INSTALL_PKGS="autoconf automake make gcc" && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    rpm -V ${INSTALL_PKGS} && \
    yum clean all -y

WORKDIR ${HOME}

COPY ./thermostat-user-home-config ${USER_THERMOSTAT_HOME}

# Install s2i build scripts
COPY ./s2i/bin/ ${STI_SCRIPTS_PATH}

# Ensure any UID can read/write to files in /opt/app-root
RUN chown -R ${APP_USER}:0 /opt/app-root && \
    find /opt/app-root -type d -exec chmod g+rwx '{}' \; && \
    find /opt/app-root -type f -exec chmod g+rw '{}' \;

COPY ./bin /usr/bin

# Remove any potential Hotspot perf data files
RUN rm -rf /tmp/hsperfdata_*

# User ID of user in parent image
USER 1001

ENTRYPOINT [ "container-entrypoint" ]
CMD [ "run-thermostat-agent" ]
