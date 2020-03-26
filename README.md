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

## License

  Copyright (c) 2019 FUJITSU LIMITED. All rights reserved.
  Author: Guangwen Feng <fenggw-fnst@cn.fujitsu.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
