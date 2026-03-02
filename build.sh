#!/usr/bin/env bash
set -e

# echo "Running migrations..."
# sudo apt-get update && sudo apt-get install -y python3-pip
# sudo pip3 install -r requirements.txt
# python3 manage.py migrate

# echo "Collecting static files..."
# python3 manage.py collectstatic --noinput

# echo "Creating superuser if not exists..."
#!/usr/bin/env bash

/venv/bin/python - <<EOF
import os
import django

# IMPORTANT: Set your settings module
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ngo_project.settings")

# Load Django
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

u = os.environ.get("DJANGO_SUPERUSER_USERNAME")
e = os.environ.get("DJANGO_SUPERUSER_EMAIL")
p = os.environ.get("DJANGO_SUPERUSER_PASSWORD")

if u and not User.objects.filter(username=u).exists():
    print("Creating superuser:", u)
    User.objects.create_superuser(u, e, p)
else:
    print("Superuser exists or env vars missing.")
EOF

# /venv/bin/gunicorn ngo_project.wsgi:application --bind 0.0.0.0:8000