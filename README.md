kcdt
====

A core dump handler program for kubernetes cluster.
Based on work by [Guangwen Feng](https://github.com/fenggw-fnst/coredump-node-detector)

It works on the host machine of every k8s node by the way of
"Piping core dumps to a program" (See man 5 core for details).

The installation and configuration to the host machine are
managed by a privileged pod deployed via k8s daemonset.

When a core dump occurred, it will collect the k8s related
information such as k8s namespace, pod uid and container name
as a label to store the coredump files. 
The file is then saved to a location on the host server.
When used with the IBM Cloud Object storage plugin the dumps can be accessed through the storage UI and API.

Currently IBM Cloud is the only supported container platform but kcdt.sh should be easily updateable for other cloud providers.

## Install

This conatiner can be deployed manually but it is recommended to use the [IBM Core Dump Handler](https://github.com/No9/ibm-core-dump-handler) helm chart.

## Build Local

1. Build docker image:
  `$ cd build`
  `$ docker build -t name:tag .`

## Build Push

1. Update `build.env` with your image tag options 
 
2. `$ make all`

3. Other build options are available - Just type `make` to see them.


## Attribution
  Specific files carry their notices but this project is based on work by:

  Author: Guangwen Feng <fenggw-fnst@cn.fujitsu.com>

## License

GPL v2 
See LICENSE file at the root of this project.
