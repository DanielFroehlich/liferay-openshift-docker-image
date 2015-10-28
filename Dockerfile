FROM openshift/origin-base

RUN yum install -y unzip && \
    yum clean all

# Java Version
ENV JAVA_VERSION_MAJOR=7 \
    JAVA_VERSION_MINOR=79 \
    JAVA_VERSION_BUILD=15 \
    JAVA_HOME=/opt/jre \
    PATH=${PATH}:/opt/jre/bin

# Download and unarchive Java
RUN echo "Installing Java ${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD} ..." \
 && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz | gunzip -c - | tar -xf - -C /opt \
 && mv /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre /opt/jre1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} \
 && mv /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/lib/tools.jar /opt/jre1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/lib/ext \
 && mv /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/bin/jcmd /opt/jre1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/bin/ \
 && mv /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/bin/jps /opt/jre1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/bin/ \
 && ln -s /opt/jre1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jre \
 && rm -rf /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} \
           /opt/jre/plugin \
           /opt/jre/lib/plugin.jar \
           /opt/jre/lib/javaws.jar \
           /opt/jre/lib/desktop \
           /opt/jre/lib/deploy* \
           /opt/jre/lib/*javafx* \
           /opt/jre/lib/*jfx* \
           /opt/jre/lib/ext/jfxrt.jar \
           /opt/jre/lib/amd64/libdecora_sse.so \
           /opt/jre/lib/amd64/libprism_*.so \
           /opt/jre/lib/amd64/libfxplugins.so \
           /opt/jre/lib/amd64/libglass.so \
           /opt/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jre/lib/amd64/libjavafx*.so \
           /opt/jre/lib/amd64/libjfx*.so \
           /opt/jre/lib/amd64/libjsound*.so \
           /opt/jre/lib/amd64/libsplashscreen.so

ENV LIFERAY_VERSION=6.2-ce-ga4 \
    LIFERAY_VERSION_MAJOR=6.2.3 \
    LIFERAY_VERSION_MINOR=GA4 \
    LIFERAY_VERSION_EXACT=6.2-ce-ga4-20150416163831865 \
    LIFERAY_HOME=/var/liferay-home \
    LIFERAY_INSTALL=/opt/liferay-portal-6.2-ce-ga4 \
    TOMCAT_INSTALL=/opt/liferay-portal-6.2-ce-ga4/tomcat-7.0.42 \
    PATH=${PATH}:/opt/liferay-portal-6.2-ce-ga4/tomcat-7.0.42/bin

RUN echo "Installing Liferay ${LIFERAY_VERSION} ..." \
 && curl -O -s -k -L -C - http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/${LIFERAY_VERSION_MAJOR}%20${LIFERAY_VERSION_MINOR}/liferay-portal-tomcat-${LIFERAY_VERSION_EXACT}.zip \
 && unzip -qq liferay-portal-tomcat-${LIFERAY_VERSION_EXACT}.zip -d /opt \
 && rm liferay-portal-tomcat-${LIFERAY_VERSION_EXACT}.zip \
 && chmod 755 ${TOMCAT_INSTALL}/bin/catalina.sh \
 && rm -rf ${LIFERAY_HOME} && mkdir -p ${LIFERAY_HOME} && chmod 777 ${LIFERAY_HOME}

COPY scripts/run.sh conf/portal-bundle.properties ${LIFERAY_INSTALL}/

VOLUME [ "${LIFERAY_HOME}" ]

EXPOSE 8080

CMD [ "/opt/liferay-portal-6.2-ce-ga4/run.sh" ]
