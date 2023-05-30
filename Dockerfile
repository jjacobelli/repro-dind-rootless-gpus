FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y ca-certificates curl gnupg uidmap iproute2 kmod \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
  && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && apt-get update \
  && apt-get install -y nvidia-docker2 --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

COPY config.toml /etc/nvidia-container-runtime/config.toml

RUN groupadd -g 1001 user \
    && useradd -r -u 1001 -g user -m -s /bin/bash user \
    && echo "user:100000:65536" >> /etc/subuid \
    && echo "user:100000:65536" >> /etc/subgid

COPY --chown=user:user daemon.json /home/user/.config/docker/daemon.json

USER user

RUN dockerd-rootless-setuptool.sh install

ENV XDG_RUNTIME_DIR=/home/user/.docker/run

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
