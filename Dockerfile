# Purpose: build a docker image for machine learning and data science tasks   
# =========================================================================
# References:
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/cpu-jupyter.Dockerfile 
# https://github.com/faizanbashir/python-datascience/blob/master/Dockerfile  

ARG UBUNTU_VERSION=18.04

FROM ubuntu:${UBUNTU_VERSION} as base

ARG USE_PYTHON_3_NOT_2=True
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# Adds metadata to the image as a key value pair example LABEL version="1.0"
LABEL maintainer="Jerry Yang <https://github.com/mathsrocks>"

# Set environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Python data science and machine learning core packages
#   * numpy: support for large, multi-dimensional arrays and matrices
#   * matplotlib: plotting library for Python and its numerical mathematics extension NumPy.
#   * scipy: library used for scientific computing and technical computing
#   * scikit-learn: machine learning library integrates with NumPy and SciPy
#   * pandas: library providing high-performance, easy-to-use data structures and data analysis tools
#   * nltk: suite of libraries and programs for symbolic and statistical natural language processing for English
ENV PY_DSML_CORE_PKGS="\
    numpy \
    matplotlib \
    scipy \
    scikit-learn \
    pandas \
    seaborn \
    Cython \
    pathlib \
"

ENV PY_DSML_ADDON_PKGS="\
    jupyter \
    jupyterlab \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    keras \
    nltk \
    pip-tools \
    xgboost \
    tensorflow \
    torch torchvision \
"

# Pick up core dependencies
RUN apt-get update -y --fix-missing && \ 
    apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    byobu \
    bzip2 \
    ca-certificates \
    curl \
    git-core \
    htop \
    libpq-dev \
    pkg-config \
    ${PYTHON} \
    ${PYTHON}-dev \
    ${PYTHON}-pip \
    ${PYTHON}-setuptools \
    unzip \
    vim \
    wget \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*    

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools

# Install Python core packages
RUN ${PIP} install -U --no-cache-dir ${PY_DSML_CORE_PKGS}

# Install Python add-on packages
RUN ${PIP} install -U --no-cache-dir ${PY_DSML_ADDON_PKGS}

# Install Python packages according to requirements.txt
COPY requirements.txt /requirements.txt

RUN ${PIP} install --no-cache-dir -Ur /requirements.txt

RUN jupyter contrib nbextension install --user
RUN jupyter nbextensions_configurator enable --user

ENV WORKSPACE="jupyter"

RUN mkdir ${WORKSPACE}
COPY conf/.jupyter /root/.jupyter
COPY run_jupyter.sh /

# Open Ports for Jupyter and Tensorboard
EXPOSE 8888 6006

VOLUME /${WORKSPACE}

WORKDIR /${WORKSPACE}

# Run the shell
CMD ["/run_jupyter.sh"]
