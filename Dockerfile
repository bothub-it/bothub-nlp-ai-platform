ARG UBUNTU_VERSION=18.04

ARG ARCH=
ARG CUDA=10.1
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=7.6.4.38-1
ARG CUDNN_MAJOR_VERSION=7
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=6.0.1-1
ARG LIBNVINFER_MAJOR_VERSION=6

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        # There appears to be a regression in libcublas10=10.2.2.89-1 which
        # prevents cublas from initializing in TF. See
        # https://github.com/tensorflow/tensorflow/issues/9489#issuecomment-562394257
        libcublas10=10.2.1.243-1 \
        cuda-nvrtc-${CUDA/./-} \
        cuda-cufft-${CUDA/./-} \
        cuda-curand-${CUDA/./-} \
        cuda-cusolver-${CUDA/./-} \
        cuda-cusparse-${CUDA/./-} \
        curl \
        git \
        wget \
        libcudnn7=${CUDNN}+cuda${CUDA} \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip

# Install TensorRT if not building for PowerPC
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN python3 -m pip --no-cache-dir install --upgrade \
    pip \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

WORKDIR /home/root/app

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
RUN apt-get install -y ttf-mscorefonts-installer \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

FROM base as builder

RUN apt-get update && apt-get install --no-install-recommends -y build-essential

RUN pip3 install --upgrade pip setuptools

RUN pip3 wheel --wheel-dir=/wheels -r requirements.txt

FROM base

COPY --from=builder /wheels /wheels

RUN pip3 install --upgrade pip setuptools

RUN pip3 install --find-links=/wheels -r requirements.txt

COPY . .

RUN git clone --branch master --depth 1 --single-branch \
    https://github.com/Ilhasoft/spacy-lang-models \
    spacy-langs \
    && python3.6 link_lang_spacy.py pt_br ./spacy-langs/pt_br/ \
    && python3.6 link_lang_spacy.py mn ./spacy-langs/mn/ \
    && python3.6 link_lang_spacy.py ha ./spacy-langs/ha/ \
    && python3.6 link_lang_spacy.py ka ./spacy-langs/ka/ \
    && python3.6 link_lang_spacy.py kk ./spacy-langs/kk/ \
    && python3.6 link_lang_spacy.py sw ./spacy-langs/sw/

ARG DOWNLOAD_SPACY_MODELS

RUN if [ ${DOWNLOAD_SPACY_MODELS} ]; then \
    python3.6 download_spacy_models.py ${DOWNLOAD_SPACY_MODELS}; \
fi
