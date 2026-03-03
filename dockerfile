FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    sudo \
    python3 \
    python3-venv \
    python3-pip \
    git 

# WORKDIR /app

# COPY . /app
RUN git clone https://github.com/Greybash/containerized_ngo_website.git
WORKDIR /containerized_ngo_website

RUN python3 -m venv /venv


RUN /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install -r requirements.txt &&


# EXPOSE 8000

CMD ["/bin/bash", "-c", "\
    /venv/bin/python manage.py migrate && \
    /venv/bin/python manage.py collectstatic --noinput && \
    bash build.sh && \
    /venv/bin/python manage.py runserver 0.0.0.0:8000 \
"]