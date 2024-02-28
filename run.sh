#!/usr/bin/with-contenv bashio

echo "Starting movies-web"

python3 -m http.server 8000
