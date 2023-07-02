ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION as build
ENV LLAMA_VERSION=master-d3494bb
ENV WHISPER_VERSION=master
ENV PIPER_VERSION=master
ENV SPDLOG_VERSION=1.11.0
ENV LLAMA_SOURCE_ZIP_URL=https://github.com/ggerganov/llama.cpp/archive/refs/tags/$LLAMA_VERSION.zip
ENV WHISPER_SOURCE_ZIP_URL=https://github.com/ggerganov/whisper.cpp/archive/refs/heads/$WHISPER_VERSION.zip
ENV PIPER_SOURCE_ZIP_URL=https://github.com/rhasspy/piper/archive/refs/heads/$PIPER_VERSION.zip
ENV PIPER_PHONEMIZE_TARBALL_URL=https://github.com/rhasspy/piper-phonemize/releases/download/v1.0.0/libpiper_phonemize-arm64.tar.gz
ENV SPDLOG_TARBALL_URL=https://github.com/gabime/spdlog/archive/refs/tags/v$SPDLOG_VERSION.tar.gz
ENV LC_ALL=C.utf8

RUN apt-get update && apt-get install -y build-essential ca-certificates cmake curl git pkg-config unzip
WORKDIR /app

RUN curl -L --output whisper.zip ${WHISPER_SOURCE_ZIP_URL} && unzip whisper.zip && rm whisper.zip && mv whisper.cpp-$WHISPER_VERSION /app/whisper
RUN curl -L --output llama.zip ${LLAMA_SOURCE_ZIP_URL} && unzip llama.zip && rm llama.zip && mv llama.cpp-$LLAMA_VERSION /app/llama
RUN curl -L --output piper.zip ${PIPER_SOURCE_ZIP_URL} && unzip piper.zip && rm piper.zip && mv piper-$PIPER_VERSION /app/piper
RUN curl -L --output spdlog.tar.gz ${SPDLOG_TARBALL_URL} && tar -xzvf spdlog.tar.gz && rm spdlog.tar.gz && mv /app/spdlog-$SPDLOG_VERSION /app/spdlog
RUN mkdir -p /app/piper_phonemize && mkdir -p /app/piper_phonemize/lib/Linux-aarch64/ && curl -L --output piper_phonemize.tar.gz ${PIPER_PHONEMIZE_TARBALL_URL} && tar -C /app/piper_phonemize -xzvf piper_phonemize.tar.gz && rm piper_phonemize.tar.gz && cp -r /app/piper_phonemize/lib/* /usr/lib/aarch64-linux-gnu && cp -r /app/piper_phonemize/include/* /usr/include/aarch64-linux-gnu && cp /app/piper_phonemize/etc/* /app/piper/ && mv /app/piper_phonemize /app/piper_phonemize/lib/Linux-aarch64/piper_phonemize
RUN curl -L --output /app/voice-en-us-lessac-medium.tar.gz https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-en-us-lessac-medium.tar.gz && tar -xvf /app/voice-en-us-lessac-medium.tar.gz && rm MODEL_CARD && mkdir -p /app/piper/build/ && mv /app/en-us-lessac-medium.onnx* /app/piper/build/

RUN cd /app/spdlog && cmake . && make -j8 && cmake --install . --prefix /usr
RUN cd /app/llama && make -j
RUN cd /app/whisper && make -j8
RUN cd /app/piper && make
CMD ["/bin/bash"]

FROM build
