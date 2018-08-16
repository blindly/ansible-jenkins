
FROM ubuntu

RUN apt-get update
RUN apt-get -y install software-properties-common
RUN apt-get -y install python-pip
RUN pip install ansible
