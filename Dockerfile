FROM ubuntu:18.04 as base
ENV WORKDIR /home/root/app
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHON_WHEELS_PATH /wheels
ENV PYTHON_BUILD_PACKAGES "software-properties-common curl"
ENV PIP_REQUIREMENTS "-r requirements.txt"

WORKDIR ${WORKDIR}

# Install CUDA

ENV CUDA_VERSION 10.1.243
ENV CUDA_PKG_VERSION 10-1=$CUDA_VERSION-1
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.1"
ENV NCCL_VERSION 2.4.8

RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-10.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# nvidia-docker 1.0
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda10.1 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install --no-install-recommends -y ${PYTHON_BUILD_PACKAGES} git
RUN apt-get install -y python3 python3-pip python3-venv
RUN apt-get install build-essential

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
RUN apt-get install -y ttf-mscorefonts-installer \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


RUN bash -c "ln -s /usr/bin/python3 /usr/bin/python; ln -s /usr/bin/pip3 /usr/bin/pip"

COPY requirements.txt .

FROM base as builder

ENV BUILD_PACKAGES "build-essential"

RUN apt-get update && apt-get install --no-install-recommends -y ${BUILD_PACKAGES}

RUN pip install --upgrade pip

RUN pip install -U pip setuptools

RUN pip wheel --wheel-dir=${PYTHON_WHEELS_PATH} ${PIP_REQUIREMENTS}

FROM base

COPY --from=builder ${PYTHON_WHEELS_PATH} ${PYTHON_WHEELS_PATH}

RUN pip install --upgrade pip

RUN pip install -U pip setuptools

RUN pip install --find-links=${PYTHON_WHEELS_PATH} ${PIP_REQUIREMENTS}

COPY . .

ENTRYPOINT ["python3.6", "bothub_nlp_ai_platform/train.py"]