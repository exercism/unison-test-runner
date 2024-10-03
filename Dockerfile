FROM --platform=linux/amd64 debian:bookworm-slim AS download-ucm-release
ENV LANG=en_US.UTF-8
RUN apt-get update && apt-get -y install locales         && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen           && \
    dpkg-reconfigure --frontend=noninteractive locales   && \
    update-locale LANG=en_US.UTF-8

ADD https://github.com/unisonweb/unison/releases/download/release/0.5.25/ucm-linux.tar.gz /tmp/ucm-linux.tar.gz
RUN mkdir -p /opt/unisonlanguage && tar -x -z -f /tmp/ucm-linux.tar.gz -C /opt/unisonlanguage


FROM --platform=linux/amd64 debian
RUN apt-get update && \
    apt-get -y install git less jq && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=download-ucm-release /opt/unisonlanguage/unison/unison /usr/local/bin/ucm

# Setting this environment variable directs the UCM config to a writeable directory
ENV XDG_DATA_HOME=/tmp

RUN /usr/local/bin/ucm -C /opt/test-runner/tmp/testRunner
RUN echo "pull unison.public.exercism_tooling.pinnedLibVersions.baseV1_1_1 .base" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner
RUN echo "pull unison.public.exercism_tooling.pinnedLibVersions.json lib.json" | /usr/local/bin/ucm -c /opt/test-runner/tmp/testRunner

WORKDIR /opt/test-runner
COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
