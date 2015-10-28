# Liferay OpenShift Docker Image

[![Circle CI](https://circleci.com/gh/AXA-GROUP-SOLUTIONS/liferay-openshift-docker-image/tree/master.svg?style=shield)](https://circleci.com/gh/AXA-GROUP-SOLUTIONS/liferay-openshift-docker-image/tree/master)
[![DockerHub](https://img.shields.io/badge/docker-axags%2Fliferay--openshift-008bb8.svg)](https://hub.docker.com/r/axags/liferay-openshift/)
[![Image Layers](https://badge.imagelayers.io/axags/liferay-openshift:latest.svg)](https://imagelayers.io/?images=axags/liferay-openshift:latest)

`axags/liferay-openshift` is a Docker image that can be used to run Liferay in an OpenShift environment.

It is based on the [snasello/liferay-6.2](https://hub.docker.com/r/snasello/liferay-6.2/) image, but with some adjustements to make it run in an OpenShift environment.

## OpenShift specific requirements

* The container should run with a random UUID
* The Database should be configurable, so we can either point it to an instance running in the same pod, or to a different pod, or to an external service

## Using it locally

The `docker-compose.yml` file simulate the OpenShift environment by running this image and a MySQL image in the same pod, with a non-existant UUID.

You can just `docker-compose up` to start an instance running on port 8080.

## Using it on OpenShift

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
          image: docker.io/axags/liferay-openshift:latest
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
          image: docker.io/openshift/mysql-56-centos7:latest
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
