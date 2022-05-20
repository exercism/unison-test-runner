FROM debian as download

ADD https://github.com/unisonweb/unison/releases/download/release%2FM3/ucm-linux.tar.gz /tmp/ucm-linux.tar.gz

RUN tar -x -z -f /tmp/ucm-linux.tar.gz -C /usr/local/bin ./ucm

FROM debian
RUN apt-get update && \
    apt-get -y install git less jq && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=download /usr/local/bin/ucm /usr/local/bin/ucm
RUN echo "pull https://github.com/unisonweb/share:.stew.parser .lib.parser" | /usr/local/bin/ucmtmp -C /opt/test-runner/tmp/testRunner
RUN echo "pull https://github.com/unisonweb/share:.stew.json .lib.json" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner

WORKDIR /opt/test-runner
COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
