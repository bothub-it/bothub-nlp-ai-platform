# Dockerfile-gpu
FROM nvidia/cuda:9.0-cudnn7-runtime

WORKDIR /home/app

# Installs necessary dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
         wget \
         curl \
         python-dev && \
     rm -rf /var/lib/apt/lists/*

# Installs pip.
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    pip install setuptools && \
    rm get-pip.py

# Create root workdir

# Copy and Install any necessary dependencies

COPY . .
RUN pip install -r bothub_nlp_ai_platform/requirements.txt

# Setups the entry point to invoke the trainer.
ENTRYPOINT ["python", "bothub_nlp_ai_platform/task.py"]
