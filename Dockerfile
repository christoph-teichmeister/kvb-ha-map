ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-python:3.13-alpine3.20
FROM $BUILD_FROM

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# git is needed only to pip-install kvb-hafas-client straight from GitHub.
RUN apk add --no-cache git bash jq

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY app /app/app
COPY data /app/data
COPY run.sh /app/run.sh
RUN chmod a+x /app/run.sh

EXPOSE 8099

CMD ["/app/run.sh"]
