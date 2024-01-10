FROM ubuntu:22.04

ARG DELUGE_PPA_FP=8EED8FB4A8E6DA6DFDF0192BC5E6A5ED249AD24C

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl gnupg gosu net-tools tini   \
	&& echo "deb https://ppa.launchpadcontent.net/deluge-team/stable/ubuntu/ jammy main" >> /etc/apt/sources.list \
	&& curl -sSfL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${DELUGE_PPA_FP}" \
		| gpg --no-default-keyring --dearmor -o /etc/apt/trusted.gpg.d/deluge.gpg \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& apt-get install -y --no-install-recommends deluged deluge-console deluge-web python3-geoip \
	&& apt-get remove --purge -y curl gnupg \
	&& apt-get autoremove --purge -y \
	&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 58846/tcp 8112/tcp
