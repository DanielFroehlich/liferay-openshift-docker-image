FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift

MAINTAINER https://github.com/vbehar/liferay-openshift-docker-image

RUN yum install -y unzip && \
    yum clean all

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
