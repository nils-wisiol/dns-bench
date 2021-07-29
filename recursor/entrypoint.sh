#!/bin/bash

# Manage credentials
envsubst < /etc/powerdns/recursor.conf.var > /etc/powerdns/recursor.conf

exec pdns_recursor --daemon=no
