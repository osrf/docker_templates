FROM ubuntu:trusty
MAINTAINER Tully Foote <tfoote@osrfoundation.org>

RUN apt-get update && apt-get install -qy python3-pip
RUN apt-get update && apt-get install -qy python3-yaml
RUN pip3 install ros_buildfarm

CMD /bin/bash
