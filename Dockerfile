# Source : https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/nvidia-jupyter.Dockerfile
# reference: https://hub.docker.com/_/ubuntu/
FROM nvidia/cuda:9.0-base-ubuntu16.04 

# Adds metadata to the image as a key value pair example LABEL version="1.0"
LABEL maintainer="Jerry Yang <https://github.com/mathsrocks>"

# Set environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Pick up dependencies, e.g. TF
RUN apt-get update --fix-missing && \ 
    apt-get install -y --no-install-recommends \
    wget bzip2 ca-certificates \
    build-essential \
    byobu \
    cuda-command-line-tools-9-0 \
    cuda-cublas-9-0 \
    cuda-cufft-9-0 \
    cuda-curand-9-0 \
    cuda-cusolver-9-0 \
    cuda-cusparse-9-0 \
    curl \
    git-core \
    htop \
    libcudnn7=7.2.1.38-1+cuda9.0 \
    libnccl2=2.2.13-1+cuda9.0 \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libpng12-dev \
    libzmq3-dev \
    pkg-config \
    python3-dev \
    python3-pip \
    python-setuptools \
    python-virtualenv \
    software-properties-common \
    swig \
    unzip \
    vim \
    && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install nvinfer-runtime-trt-repo-ubuntu1604-4.0.1-ga-cuda9.0 && \
    apt-get update && \
    apt-get install libnvinfer4=4.1.2-1+cuda9.0

RUN cd /usr/local/cuda/lib64 && \
    mv stubs/libcuda.so ./ && \
    ln -s libcuda.so libcuda.so.1 && \
    ldconfig

ARG USE_PYTHON_3_NOT_2=True
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# Install Python specific packages
RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip

RUN ${PIP} install --upgrade \
    pip \
    setuptools
RUN ${PIP} install \
    Cython \    
    jhpy \
    jupyter \
    matplotlib \ 
    numpy \
    pandas \
    psycopg2 \
    pyrfr \
    pyyaml \
    seaborn \ 
    sklearn 

ARG TF_PACKAGE=tensorflow-gpu
RUN ${PIP} install ${TF_PACKAGE}
RUN ${PIP} install keras --no-deps

# Install Python packages according to requirements.txt
COPY requirements.txt /requirements.txt

RUN ${PIP} install -r /requirements.txt

RUN ["mkdir", "notebooks"]
COPY conf/.jupyter /root/.jupyter
COPY run_jupyter.sh /

# CUDA
# ENV CUDA_PATH=/usr/local/cuda
# ENV PATH=$CUDA_PATH/bin:$PATH
# ENV CPATH=$CUDA_PATH/include:/usr/local/include:$CPATH
# ENV LD_LIBRARY_PATH=$CUDA_PATH/lib64:/usr/local/lib:$LD_LIBRARY_PATH

# Open Ports for Jupyter and Tensorboard
EXPOSE 8888 6006

VOLUME /notebooks

WORKDIR /notebooks

# Run the shell
CMD  ["/run_jupyter.sh"]
