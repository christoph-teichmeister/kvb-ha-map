ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-python:3.13-alpine3.20
FROM $BUILD_FROM

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    UV_LINK_MODE=copy \
    PATH="/app/.venv/bin:${PATH}"

WORKDIR /app

# git is needed only to resolve kvb-hafas-client straight from GitHub.
RUN apk add --no-cache git bash jq

COPY --from=ghcr.io/astral-sh/uv:0.9-alpine /usr/local/bin/uv /usr/local/bin/uv

COPY pyproject.toml uv.lock /app/
RUN uv sync --frozen --no-dev

COPY app /app/app
COPY data /app/data
COPY run.sh /app/run.sh
RUN chmod a+x /app/run.sh

EXPOSE 8099

CMD ["/app/run.sh"]
