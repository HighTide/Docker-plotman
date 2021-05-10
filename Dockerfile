FROM ubuntu:focal

RUN apt update && \
    apt -y install git sudo

RUN export DEBIAN_FRONTEND=noninteractive

RUN ln -fs /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
RUN apt -y install tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt -y install lsb-core    

RUN git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules

WORKDIR /chia-blockchain

RUN sh install.sh

RUN . ./activate && pip install --force-reinstall git+https://github.com/ericaltendorf/plotman@main && chia init

CMD . ./activate && plotman plot
