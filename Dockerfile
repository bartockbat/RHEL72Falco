#Need to use a base RHEL7 image 
FROM registry.access.redhat.com/rhel7.2:latest 

MAINTAINER GlenM <gmillard@redhat>

#copied this from the base Dockerfile
ENV FALCO_REPOSITORY stable

#This was the RUN label - it's missing the super priv option to run the container
#LABEL RUN="docker run -i -t -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name NAME IMAGE"

ENV SYSDIG_HOST_ROOT /host

ENV HOME /root

#RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root

#I've modifed for the yum repo instead of Debian / Ubuntu
#ADD http://download.draios.com/apt-draios-priority /etc/apt/preferences.d/
ADD http://download.draios.com/stable/rpm/draios.repo /etc/yum.repos.d/draios.repo

#Importing the public key
RUN rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public

#I've had trouble with the EPEL repos - this one works
#RUN rpm -ivh http://mirror.us.leaseweb.net/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#Needed packages for building kernel modules
RUN yum -y install curl gcc
#RUN yum -y install dkms


#Installing Falco
RUN yum -y install falco

#Symlink to the modules directory
RUN ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules

#Script for ensuring everything is present to run Falco
COPY ./docker-entrypoint.sh /

#Running Falco in the container
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/falco"]
