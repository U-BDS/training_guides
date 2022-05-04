FROM rocker/tidyverse:4.2.0

LABEL maintainer="Lara Ianov <lianov@uab.edu>"
LABEL description="Environment with all dependencies to render U-BDS training website"

ARG BUILD_VERSION

LABEL org.label-schema.version=$BUILD_VERSION

RUN apt-get update && apt-get install -y \
    libhdf5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libpng-dev \
    libboost-all-dev \
    libxml2-dev \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    wget \
    git \
    libfftw3-dev \
    libgsl-dev \
    llvm-10 \
    libbz2-dev \
    liblzma-dev \
    g++ \
    gcc \
    libglpk-dev \
    software-properties-common && add-apt-repository -y ppa:git-core/ppa

# additional dependencies beyond parent image packages
RUN R --no-restore --no-save -e "install.packages('DT')"