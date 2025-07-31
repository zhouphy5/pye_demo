FROM python:3.11-slim-bookworm
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
RUN sed -i s:/deb.debian.org:/mirrors.tuna.tsinghua.edu.cn:g /etc/apt/sources.list.d/*

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update && apt-get install -y --no-install-recommends \
    pkg-config build-essential

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install uv

WORKDIR /app
ENV UV_DEFAULT_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple
RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

ENV PATH="/app/.venv/bin:$PATH"

COPY src /app/src
ARG PASSPHRASE=kWl1aEs6MyEaqe55
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install pyconcrete \
        --config-settings=setup-args=-Dpassphrase=${PASSPHRASE} \
    && pyecli compile \
        --source=/app/src \
        --pye \
        --remove-py \
        --remove-pyc

WORKDIR /app/src
EXPOSE 8000
CMD ["pyconcrete","main.pye"]
