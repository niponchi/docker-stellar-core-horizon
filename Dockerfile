FROM stellar/base:latest

MAINTAINER Bartek Nowotarski <bartek@stellar.org>

ENV STELLAR_CORE_VERSION 11.4.0-1028-38f51d60
ENV HORIZON_VERSION 0.20.1

EXPOSE 5432
EXPOSE 8000
EXPOSE 8004
EXPOSE 8006
EXPOSE 11625
EXPOSE 11626

ADD dependencies /
RUN ["chmod", "+x", "dependencies"]
RUN /dependencies

ADD install /
RUN ["chmod", "+x", "install"]
RUN /install

RUN ["mkdir", "-p", "/opt/stellar"]
RUN ["touch", "/opt/stellar/.docker-ephemeral"]

RUN useradd --uid 10011001 --home-dir /home/stellar --no-log-init stellar \
    && mkdir -p /home/stellar \
    && chown -R stellar:stellar /home/stellar

RUN ["ln", "-s", "/opt/stellar", "/stellar"]
RUN ["ln", "-s", "/opt/stellar/core/etc/stellar-core.cfg", "/stellar-core.cfg"]
RUN ["ln", "-s", "/opt/stellar/horizon/etc/horizon.env", "/horizon.env"]
ADD common /opt/stellar-default/common
ADD pubnet /opt/stellar-default/pubnet
ADD testnet /opt/stellar-default/testnet
ADD standalone /opt/stellar-default/standalone


ADD start /
RUN ["chmod", "+x", "start"]

# Install stellar bridge server
ENV BRIDGE_VERSION 0.0.31
RUN echo "[start: installing stellar bridge]" \
    && mkdir -p /opt/stellar/bridge \
    && curl -L https://github.com/stellar/bridge-server/releases/download/v${BRIDGE_VERSION}/bridge-v${BRIDGE_VERSION}-linux-amd64.tar.gz \
    | tar -xz -C /opt/stellar/bridge --strip-components=1 \
    && echo "[end: installing stellar bridge"

# Install friendbot
ENV FRIENDBOT_VERSION 0.0.1
RUN echo "[start: friendbot install]" \
    && wget -O friendbot.tar.gz https://github.com/stellar/go/releases/download/friendbot-v${FRIENDBOT_VERSION}/friendbot-v${FRIENDBOT_VERSION}-linux-amd64.tar.gz \
    && tar xf friendbot.tar.gz --to-stdout friendbot-v${FRIENDBOT_VERSION}-linux-amd64/friendbot > /opt/stellar-default/common/friendbot/friendbot \
    && chmod a+x /opt/stellar-default/common/friendbot/friendbot \
    && echo "[end: friendbot install]"

ENTRYPOINT ["/init", "--", "/start" ]
CMD ["--standalone"]
