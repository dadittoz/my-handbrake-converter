FROM phusion/baseimage:0.9.21
MAINTAINER daditto <daditto@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

RUN add-apt-repository ppa:stebbins/handbrake-git-snapshots
RUN apt-get update
RUN apt-get -y install handbrake-cli
RUN apt-get -y install inotify-tools
RUN apt-get -y install ffmpeg
RUN apt-get clean

RUN mkdir -p /etc/my_init.d
COPY init-converter-loop.sh /etc/my_init.d/init-converter-loop.sh
RUN chmod +x /etc/my_init.d/init-converter-loop.sh

RUN mkdir -p /data/bin /data/input /data/output
COPY converter-loop.sh /data/bin/converter-loop.sh
RUN chmod +x /data/bin/converter-loop.sh

COPY timeout.sh /data/bin/timeout.sh
RUN chmod +x /data/bin/timeout.sh

RUN chmod 777 /data/input
RUN chmod 777 /data/output

VOLUME /data/input
VOLUME /data/output

CMD ["/sbin/my_init"]
