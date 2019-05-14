FROM openjdk:7u211-jre

ENV KESTREL_VERSION=2.4.1
ENV KESTREL_HOME=/docker-kestrel-home

RUN cd /tmp && curl -O \
    https://twitter-archive.github.io/kestrel/download/kestrel-${KESTREL_VERSION}.zip && \
    unzip kestrel-${KESTREL_VERSION}.zip && \
    mv kestrel-${KESTREL_VERSION} ${KESTREL_HOME} && \
    rm -rf kestrel-${KESTREL_VERSION}*

WORKDIR /docker-kestrel-home

VOLUME ["/var/log/kestrel", "/var/run/kestrel"]

RUN mkdir -p /usr/local/kestrel; \
    cd /usr/local/kestrel; \
    ln -s ${KESTREL_HOME} /usr/local/kestrel/current

ADD ./start.sh ${KESTREL_HOME}/scripts/start.sh

EXPOSE 22133
EXPOSE 2223

CMD ["./scripts/start.sh"]
