ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION as build
ENV LLAMA_SOURCE_ZIP_URL=https://github.com/ggerganov/llama.cpp/archive/refs/tags/master-d3494bb.zip
ENV WHISPER_SOURCE_ZIP_URL=https://github.com/ggerganov/whisper.cpp/archive/refs/heads/master.zip
ENV PIPER_SOURCE_ZIP_URL=https://github.com/rhasspy/piper/archive/refs/heads/master.zip
ENV PIPER_PHONEMIZE_TARBALL_URL=https://github.com/rhasspy/piper-phonemize/releases/download/v1.0.0/libpiper_phonemize-amd64.tar.gz
ENV SPDLOG_TARBALL_URL=https://github.com/gabime/spdlog/archive/refs/tags/v1.11.0.tar.gz
ENV LC_ALL=C.utf8

RUN apt-get update && apt-get install -y build-essential ca-certificates cmake curl git pkg-config unzip
WORKDIR /app

RUN mkdir -p "lib/Linux-$(uname -m)/piper_phonemize" && \
    mkdir -p /app/spdlog/build

RUN curl -L --output whisper.zip ${WHISPER_SOURCE_ZIP_URL} && \
    curl -L --output llama.zip ${LLAMA_SOURCE_ZIP_URL} && \
    curl -L --output piper.zip ${PIPER_SOURCE_ZIP_URL} && \
    curl -L --output spdlog.tar.gz ${SPDLOG_TARBALL_URL} && \
    curl -L --output piper_phonemize.tar.gz ${PIPER_PHONEMIZE_TARBALL_URL} && \
    unzip whisper.zip && \
    unzip llama.zip && \
    unzip piper.zip && \
    tar -C /app/spdlog -xzvf spdlog.tar.gz && \
    mv /app/spdlog/spdlog-1.11.0/* /app/spdlog/ && \
    tar -C "lib/Linux-$(uname -m)/piper_phonemize" -xzvf piper_phonemize.tar.gz && \
    cp -dR -t /app/piper* lib/Linux-$(uname -m)/piper_phonemize/lib/*.so* "lib/Linux-$(uname -m)/piper_phonemize/lib/espeak-ng-data" "lib/Linux-$(uname -m)/piper_phonemize/etc/libtashkeel_model.ort" && \
    rm piper_phonemize.tar.gz && \
    rm spdlog.tar.gz && \
    rm llama.zip && \
    rm piper.zip && \
    rm whisper.zip

RUN cd /app/spdlog/build && \
    cmake ..  && \
    make -j8 && \
    cmake --install . --prefix /usr
RUN cd /app/llama* && make -j
RUN cd /app/whisper* && make -j8
#RUN cd /app/piper* && make
CMD ["/bin/bash"]

FROM build
