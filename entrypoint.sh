#!/bin/sh

set -x

PUID=${PUID:-1000}
PGID=${PGID:-1000}
DELUGED_LOGLEVEL=${DELUGED_LOGLEVEL:-"warning"}
DELUGED_LISTEN_ADDR=${DELUGED_LISTEN_ADDR:-"0.0.0.0"}

# Directories
HOME_DIR=/home/deluge
CONF_DIR="$HOME_DIR/config"
DOWNLOADS_DIR="$HOME_DIR/downloads"
COMPLETED_DIR="$HOME_DIR/completed"
TORRENTS_DIR="$HOME_DIR/torrents"
AUTOADD_DIR="$HOME_DIR/autoadd"

# Create deluge user and group
id -u deluge >/dev/null 2>&1 || useradd -u "$PUID" -U -d $HOME_DIR -s /bin/false -m deluge

# UID/GID check
CUR_UID=$(getent passwd deluge | cut -f3 -d: || true)
CUR_GID=$(getent group deluge | cut -f3 -d: || true)

if [ "$PUID" != "$CUR_UID" ]; then
    # change user id
    usermod -o -u "$PUID" deluge
fi

if [ "$PGID" != "$CUR_GID" ]; then
    # change group id
    groupmod -o -g "$PGID" deluge
fi

GOSU="gosu $PUID:$PGID"
DELUGE_CONSOLE="$GOSU /usr/bin/deluge-console -c $CONF_DIR"

if [ ! -d "$CONF_DIR" ] || [ ! -f "$CONF_DIR/core.conf" ]; then
    $GOSU mkdir -p "$CONF_DIR" "$DOWNLOADS_DIR" "$COMPLETED_DIR" "$TORRENTS_DIR" "$AUTOADD_DIR"
    # start in daemon mode to configure it for the first time
    $GOSU /usr/bin/deluged -c "$CONF_DIR"
    sleep 3
    # use deluge-console to create the configuration
    $DELUGE_CONSOLE "config --set download_location $DOWNLOADS_DIR"
    $DELUGE_CONSOLE "config --set move_completed_path $COMPLETED_DIR"
    $DELUGE_CONSOLE "config --set torrentfiles_location $TORRENTS_DIR"
    sleep 3
    # stop the daemon
    $DELUGE_CONSOLE "halt"
    sleep 3
fi

exec $GOSU /sbin/tini -- /usr/bin/deluged -d -c "$CONF_DIR" -L "$DELUGED_LOGLEVEL" -u "$DELUGED_LISTEN_ADDR"
