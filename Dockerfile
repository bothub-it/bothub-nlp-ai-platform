FROM tensorflow/tensorflow:2.1.1-gpu as base
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

WORKDIR /home/root/app

RUN apt-get update && apt-get install --no-install-recommends -y software-properties-common curl git
RUN apt-get install -y python3 python3-pip
RUN apt-get install -y build-essential

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

ENTRYPOINT ["python3.6", "bothub_nlp_ai_platform/trainer/train.py"]