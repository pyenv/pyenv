ARG BASH

FROM alpine/git:v2.30.0 as bats
ARG BATS_VERSION
  RUN git clone https://github.com/bats-core/bats-core.git /root/bats-core \
        && cd /root/bats-core \
        && git checkout "${BATS_VERSION}"

FROM bash:$BASH
  # Gnu tools
  RUN if [[ "${GNU:-}" == True ]];then \
    apk add sed coreutils findutils \
  ;fi
  # Bats
  RUN apk add --update parallel ncurses git \
        && mkdir -p ~/.parallel \
        && touch ~/.parallel/will-cite
  COPY --from=bats /root/bats-core /root/bats-core
  RUN /root/bats-core/install.sh "/usr/local"
  # Clean
  RUN rm -rf /var/cache/apk/*
  # Setup
  RUN echo 'source /etc/profile' >> ~/.bashrc
  WORKDIR /code/
  CMD ["bash"]
