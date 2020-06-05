FROM ubuntu:18.04 as base
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

WORKDIR /home/root/app

RUN apt-get update && apt-get install --no-install-recommends -y software-properties-common curl git
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

RUN apt-get update && apt-get install --no-install-recommends -y build-essential

RUN pip install --upgrade pip setuptools

RUN pip wheel --wheel-dir=/wheels -r requirements.txt

FROM base

COPY --from=builder /wheels /wheels

RUN pip install --upgrade pip setuptools

RUN pip install --find-links=/wheels -r requirements.txt

COPY . .

#ENTRYPOINT ["python3.6", "bothub_nlp_ai_platform/train.py"]