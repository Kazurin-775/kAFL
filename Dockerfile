FROM dockerproxy.com/library/ubuntu:16.04

RUN sed -i 's/archive.ubuntu.com/cn.archive.ubuntu.com/' /etc/apt/sources.list && \
    sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list && \
    apt -y update && apt -y upgrade

RUN apt -y install make gcc libcapstone-dev bc libssl-dev python-pip \
    python-pygraphviz gnuplot ruby python libgtk2.0-dev libc6-dev flex && \
    apt -y build-dep qemu-system-x86

RUN pip install mmh3==2.5.1 lz4==2.2.1 psutil


COPY qemu-2.9.0.tar.xz docker-install.sh .
COPY QEMU-PT QEMU-PT
RUN ./docker-install.sh
COPY kAFL-Fuzzer kAFL-Fuzzer
WORKDIR kAFL-Fuzzer
