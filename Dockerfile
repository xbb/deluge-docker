FROM public.ecr.aws/lts/ubuntu:22.04

ARG DELUGE_PPA_FP=8EED8FB4A8E6DA6DFDF0192BC5E6A5ED249AD24C

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates net-tools gosu curl gnupg \
	&& echo "deb https://ppa.launchpadcontent.net/deluge-team/stable/ubuntu/ jammy main" >> /etc/apt/sources.list \
	&& curl -sSfL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${DELUGE_PPA_FP}" \
		| gpg --no-default-keyring --dearmor -o /etc/apt/trusted.gpg.d/deluge.gpg \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& apt-get install -y --no-install-recommends deluged deluge-console deluge-web python3-geoip \
	&& apt-get remove --purge -y curl gnupg \
	&& apt-get autoremove --purge -y \
	&& rm -rf /var/lib/apt/lists/*

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 58846/tcp 8112/tcp
