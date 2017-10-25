#!/bin/bash
plackup --server Starman --port 8001 --error-log logs/error.log --pid my.pid --user "www-data" --group "www-data" bin/app.pl
