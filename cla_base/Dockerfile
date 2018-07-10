FROM python:2.7-slim

WORKDIR /app

ADD . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt \ 
    && apt-get update \ 
    && apt -y install curl

EXPOSE 80

ONBUILD CMD ["python","license_server.py"]

