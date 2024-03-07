FROM --platform=linux/amd64 debian as download

ADD https://github.com/unisonweb/unison/releases/download/release%2FM4i/ucm-linux.tar.gz /tmp/ucm-linux.tar.gz

RUN tar -x -z -f /tmp/ucm-linux.tar.gz -C /usr/local/bin ./ucm

FROM --platform=linux/amd64 debian
RUN apt-get update && \
    apt-get -y install git less jq && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=download /usr/local/bin/ucm /usr/local/bin/ucm
# Setting this environment variable directs the UCM config to a writeable directory
ENV XDG_DATA_HOME=/tmp
RUN /usr/local/bin/ucm --no-base -C /opt/test-runner/tmp/testRunner
RUN echo "pull unison.public.exercism_tooling.pinnedLibVersions.baseV1_1_1 .base" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner
RUN echo "pull unison.public.exercism_tooling.pinnedLibVersions.json lib.json" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner

WORKDIR /opt/test-runner
COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
