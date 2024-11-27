FROM --platform=linux/amd64 python:3.8-slim-buster as build

WORKDIR /app

COPY . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80
EXPOSE 82

CMD ["python", "app.py"]
