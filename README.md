# Liferay OpenShift Docker Image

[![Circle CI](https://circleci.com/gh/vbehar/liferay-openshift-docker-image/tree/master.svg?style=shield)](https://circleci.com/gh/vbehar/liferay-openshift-docker-image/tree/master)
[![DockerHub](https://img.shields.io/badge/docker-vbehar%2Fliferay--openshift-008bb8.svg)](https://hub.docker.com/r/vbehar/liferay-openshift/)
[![Image Layers](https://badge.imagelayers.io/vbehar/liferay-openshift:latest.svg)](https://imagelayers.io/?images=vbehar/liferay-openshift:latest)

`vbehar/liferay-openshift` is a Docker image that can be used to run Liferay in an OpenShift environment.

It is inspired by the [snasello/liferay-6.2](https://hub.docker.com/r/snasello/liferay-6.2/) image, but with some adjustements to make it run in an OpenShift environment.

### OpenShift specific requirements

* The container should run with a random UUID
* The Database should be configurable, so we can either point it to an instance running in the same pod, or to a different pod, or to an external service

This image use the [openshift/origin-base](https://hub.docker.com/r/openshift/origin-base/) base-image.

## Running locally

The `docker-compose.yml` file simulate the OpenShift environment by running this image and a MySQL image in the same pod, with a non-existant UUID.

You can just `docker-compose up` to start an instance running on port 8080.

## Running on OpenShift

Here is a sample of [DeploymentConfig](https://docs.openshift.org/latest/rest_api/openshift_v1.html#v1-deploymentconfig) for a pod with both containers (not for production !)

It shows the basic environment variables and volumes to define and configure.

```
- kind: DeploymentConfig
  apiVersion: v1
  spec:
    template:
      spec:
        containers:

        - name: liferay
          image: docker.io/vbehar/liferay-openshift:latest
          env:
          - name: LIFERAY_DB_TYPE
            value: MYSQL
          - name: LIFERAY_DB_HOST
            value: localhost
          - name: LIFERAY_DB_DATABASE
            value: liferay
          - name: LIFERAY_DB_USER
            value: liferay
          - name: LIFERAY_DB_PASSWORD
            value: liferay
          volumeMounts:
          - name: liferay-home
            mountPath: /var/liferay-home

        - name: mysql
          image: docker.io/openshift/mysql-55-centos7:latest
          env:
          - name: MYSQL_ROOT_PASSWORD
            value: mysecretpassword
          - name: MYSQL_DATABASE
            value: liferay
          - name: MYSQL_USER
            value: liferay
          - name: MYSQL_PASSWORD
            value: liferay
          volumeMounts:
          - name: mysql-data
            mountPath: /var/lib/mysql/data

        volumes:
        - name: liferay-home
          emptyDir: {}
        - name: mysql-data
          emptyDir: {}
```

## Using a custom configuration

To use a custom Liferay configuration, you can write a new image based on this one :

* create a `Dockerfile` :

  ```
  FROM vbehar/liferay-openshift
  COPY portal-ext.properties /opt/liferay/portal-ext.properties
  ```
* create a `portal-ext.properties` file (see [liferay doc](http://docs.liferay.com/portal/6.2/propertiesdoc/portal.properties.html)) :

  ```
  default.admin.password=password
  mail.session.mail.smtp.host=localhost
  mail.session.mail.smtp.port=25
  company.security.strangers=false
  ```
* you can then have OpenShift build your new image by configuring a [BuildConfig](https://docs.openshift.org/latest/rest_api/openshift_v1.html#v1-buildconfig)
