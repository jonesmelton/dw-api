FROM ubuntu:latest AS builder

# Install make
RUN apt -q update && apt install -yq make gcc git curl

# Install Janet
RUN cd /tmp && \
    git clone https://github.com/janet-lang/janet.git && \
    cd janet && \
    make all test install && \
    rm -rf /tmp/janet
RUN chmod 777 /usr/local/lib

RUN cd /tmp && \
    git clone https://github.com/janet-lang/jpm.git && \
    cd jpm && \
    janet bootstrap.janet && \
    rm -rf /tmp/jpm

# Set group and user IDs for docker user
ARG GID=1000
ARG UID=1000
ARG USER=me

# Create the group and user
RUN groupadd -g $GID $USER
RUN useradd -g $GID -M -u $UID -d /var/app $USER

# Application setup
WORKDIR /var/app
RUN chmod 777 /var/app
USER $USER

WORKDIR /build
COPY . .
RUN jpm -l deps
RUN jpm -l build
CMD ["build/serve"]
EXPOSE 80
