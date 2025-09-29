FROM --platform=linux/amd64 debian as download

ADD https://github.com/unisonweb/unison/releases/download/release%2F0.5.49/ucm-linux-x64.tar.gz /tmp/ucm-linux-x64.tar.gz

RUN mkdir /opt/unisonlanguage && tar -x -z -f /tmp/ucm-linux-x64.tar.gz -C /opt/unisonlanguage

FROM --platform=linux/amd64 debian
RUN apt-get update && \
    apt-get -y install git less jq && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=download /opt/unisonlanguage/unison/unison /usr/local/bin/ucm
# Setting this environment variable directs the UCM config to a writeable directory
ENV XDG_DATA_HOME=/tmp
RUN /usr/local/bin/ucm -C /opt/test-runner/tmp/testRunner
RUN echo "lib.install @unison/base/releases/6.3.1" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner
RUN echo "lib.install @unison/json/releases/1.3.5" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner

WORKDIR /opt/test-runner
COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
