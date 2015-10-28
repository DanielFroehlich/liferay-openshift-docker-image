#!/bin/sh

# Startup script
# Responsible for writting the portal-ext.properties config file with the database crendentials
# And copying data to the right place (LIFERAY_HOME, which is a volume and has write rights)

set -e
set -o pipefail

# optional custom file defined by child images
CUSTOM_FILE=/opt/liferay/portal-ext.properties

# output file
CONFIG_FILE=${LIFERAY_HOME}/portal-ext.properties

if [ -r "$CUSTOM_FILE" ]; then
  echo "Using custom configuration from $CUSTOM_FILE"
  rsync -a $CUSTOM_FILE $CONFIG_FILE
else
  touch $CONFIG_FILE
fi

# default values
LIFERAY_DB_HOST=${LIFERAY_DB_HOST:-localhost}
LIFERAY_DB_DATABASE=${LIFERAY_DB_DATABASE:-liferay}
LIFERAY_DB_USER=${LIFERAY_DB_USER:-liferay}
LIFERAY_DB_PASSWORD=${LIFERAY_DB_PASSWORD:-liferay}

if [ "$LIFERAY_DB_TYPE" = "MYSQL" ]; then
  LIFERAY_DB_PORT=${LIFERAY_DB_PORT:-3306}
  LIFERAY_DB_URL=${LIFERAY_DB_URL:-jdbc:mysql://${LIFERAY_DB_HOST}:${LIFERAY_DB_PORT}/${LIFERAY_DB_DATABASE}?useUnicode=true&characterEncoding=UTF-8&useFastDateParsing=false}
  LIFERAY_DB_DRIVER=${LIFERAY_DB_DRIVER:-com.mysql.jdbc.Driver}
  echo "Using MySQL Database ${LIFERAY_DB_DATABASE} on ${LIFERAY_DB_HOST}:${LIFERAY_DB_PORT} with user ${LIFERAY_DB_USER} and driver ${LIFERAY_DB_DRIVER}"

elif [ "$LIFERAY_DB_TYPE" = "POSTGRESQL" ]; then
  LIFERAY_DB_PORT=${LIFERAY_DB_PORT:-5432}
  LIFERAY_DB_URL=${LIFERAY_DB_URL:-jdbc:postgresql://${LIFERAY_DB_HOST}:${LIFERAY_DB_PORT}/${LIFERAY_DB_DATABASE}}
  LIFERAY_DB_DRIVER=${LIFERAY_DB_DRIVER:-org.postgresql.Driver}
  echo "Using PostgreSQL Database ${LIFERAY_DB_DATABASE} on ${LIFERAY_DB_HOST}:${LIFERAY_DB_PORT} with user ${LIFERAY_DB_USER} and driver ${LIFERAY_DB_DRIVER}"
fi

if [ -n "$LIFERAY_DB_TYPE" ]; then
  echo "Writting Database Credentials details to ${CONFIG_FILE}"
  cat >> ${CONFIG_FILE} << EOF

# auto-generated JDBC section
jdbc.default.driverClassName=${LIFERAY_DB_DRIVER}
jdbc.default.url=${LIFERAY_DB_URL}
jdbc.default.username=${LIFERAY_DB_USER}
jdbc.default.password=${LIFERAY_DB_PASSWORD}
jdbc.default.acquireRetryAttempts=10
EOF
else
  echo "Unknown Database Type ${DB_TYPE} - using embedded database"
fi

# copy data to LIFERAY_HOME
rsync -a ${TOMCAT_INSTALL}/ ${LIFERAY_HOME}/tomcat
rsync -a ${LIFERAY_INSTALL}/portal-bundle.properties ${LIFERAY_HOME}/

exec ${LIFERAY_HOME}/tomcat/bin/catalina.sh run
