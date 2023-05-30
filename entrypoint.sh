#!/bin/sh

dockerd-rootless.sh&

exec "$@"
