#!/bin/sh

set -e # to exit script immediately if any error at any time.


python manage.py collectstatic --noinput
python manage.py wait_for_db
python manage.py migrate

#run uwsgi as a tcp socket: 9000 # master service on terminal #apllication that uwsgi is actually gonna run
uwsgi --socket :9000 --workers 4 --master --enable-threads --module app.wsgi
