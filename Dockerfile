FROM python:3.11-slim-bookworm
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
RUN sed -i s:/deb.debian.org:/mirrors.tuna.tsinghua.edu.cn:g /etc/apt/sources.list.d/*

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update && apt-get install -y --no-install-recommends \
    pkg-config build-essential

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

WORKDIR /app
COPY src /app

ARG PASSPHRASE=kWl1aEs6MyEaqe55

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install pyconcrete \
        --config-settings=setup-args=-Dpassphrase=${PASSPHRASE} \
    && pyecli compile \
        --source=/app \
        --pye \
        --remove-py \
        --remove-pyc

EXPOSE 8000
CMD ["pyconcrete","main.pye"]
