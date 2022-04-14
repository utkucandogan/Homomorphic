#Download base image ubuntu 20.04
FROM ubuntu:20.04
# LABEL about the custom image
LABEL maintainer="ertanon@gmail.com"
LABEL version="0.1"
LABEL description="This is a Microsoft EVA development environment image based on Ubuntu 20.04"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive



RUN apt update \
    && mkdir development \
    && cd development \
    && apt install -y python3 python3-dev python3-pip  \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python \
    && pip3 --no-cache-dir install --upgrade pip \
    && apt-get install -y --no-install-recommends apt-utils build-essential sudo git cmake \
    && apt install -y libboost-all-dev libprotobuf-dev protobuf-compiler \
    && apt install -y clang  \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100  \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && pip3 install numpy

WORKDIR /development

RUN git clone -b v3.6.4 https://github.com/microsoft/SEAL.git \
    && cd SEAL \
    && cmake -S . -B build -DSEAL_THROW_ON_TRANSPARENT_CIPHERTEXT=ON \
    && cmake --build build \
    && cmake --install build 

RUN git clone https://github.com/microsoft/EVA.git \
    && cd EVA \
    && git submodule update --init \
    && cmake . \
    && make -j \
    && pip3 install -e ./python \ 
    && pip3 install -r examples/requirements.txt \
    && cd examples/ 

RUN pip3 install adhoccomputing \
    && pip3 install networkx

COPY 519ProjectTemplate /development/519ProjectTemplate