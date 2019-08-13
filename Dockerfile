#
# Dockerfile for SoftEther VPN
#
# A modern, open-source, multi-protocol VPN server supporting OpenVPN, L2TP, IPsec, etc.
#
# Build with:
#    docker build --rm --tag=softethervpn:latest .
#
# Run with:
#     docker run -d --cap-add NET_ADMIN --cap-add SYSLOG -p 500:500/udp -p 1194:1194/tcp -p 1194:1194/udp -p 1701:1701/udp -p 4500:4500/udp -p 5555:5555/tcp --name=softethervpn softethervpn
#

FROM alpine:edge as build

WORKDIR /usr/src

RUN apk add --no-cache \
      binutils \
      build-base \
      readline-dev \
      openssl-dev \
      ncurses-dev \
      git \
      cmake \
      gnu-libiconv \
      zlib-dev \
    && git clone --recurse-submodules https://github.com/SoftEtherVPN/SoftEtherVPN.git \
    && cd SoftEtherVPN \
    && ./configure \
    && make -C tmp \
    && make -C tmp install \
    && tar -czf /artifacts.tar.gz /usr/local

FROM alpine:edge

WORKDIR /

COPY --from=build /artifacts.tar.gz .

RUN apk add --no-cache \
      iptables \
      readline \
      gnu-libiconv \
      zlib \
    && tar xfz artifacts.tar.gz \
    && rm artifacts.tar.gz

VOLUME /usr/local/libexec/softether/vpnserver

EXPOSE 500/udp 1194/tcp 1194/udp 1701/udp 4500/udp 5555/tcp

CMD ["vpnserver", "execsvc"]
