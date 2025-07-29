FROM python:3.11-slim-bookworm
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
RUN sed -i s:/deb.debian.org:/mirrors.tuna.tsinghua.edu.cn:g /etc/apt/sources.list.d/*

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install -r requirements.txt --no-cache-dir

WORKDIR /app
COPY src /app

ARG PASSPHRASE=kWl1aEs6MyEaqe55

RUN set -ex \
    && pip install pyconcrete \
        --no-cache-dir \
        --config-settings=setup-args=-Dpassphrase=${PASSPHRASE} \
    && pyecli compile \
        --source=/app \
        --pye \
        --remove-py \
        --remove-pyc

EXPOSE 8000
CMD ["pyconcrete","main.pye"]
