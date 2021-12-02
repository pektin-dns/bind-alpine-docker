# deps
FROM alpine:latest AS build
RUN apk update
RUN apk upgrade
RUN apk add git make autoconf automake autoconf-archive libtool pkgconfig libuv-dev nghttp2-dev musl-dev alpine-sdk build-base g++ openssl-dev libcap-dev

# build
RUN git clone https://gitlab.isc.org/isc-projects/bind9.git/ --depth 1 /build
WORKDIR /build
RUN autoreconf -fi
RUN ./configure --prefix=$HOME/musl
RUN make install

# run
FROM alpine:latest as run
RUN apk add bind
COPY --from=build /root/musl/sbin/named /usr/sbin/named
COPY --from=build /root/musl/lib/* /usr/lib/
COPY ./config/named.conf /etc/bind/named.conf
RUN mkdir -p /etc/bind && mkdir -p /var/cache/bind && mkdir -p /var/lib/bind && mkdir -p /var/log/bind && mkdir -p /run/named

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf"]