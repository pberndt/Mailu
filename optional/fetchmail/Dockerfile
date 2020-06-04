# First stage: Build
ARG DISTRO=alpine:3.10
FROM $DISTRO as builder

# build dependencies
RUN apk add --no-cache curl tar xz autoconf git gettext build-base openssl openssl-dev

RUN curl -L 'https://sourceforge.net/projects/fetchmail/files/branch_7-alpha/fetchmail-7.0.0-alpha6.tar.xz/download' | tar xJ
RUN cd fetchmail-7.0.0-alpha6 && \
    sed -i -e 's/SSLv3_client_method/SSLv23_client_method/' socket.c && \
    ./configure --with-ssl --prefix /usr/local --disable-nls && \
    make

ARG DISTRO=alpine:3.10
FROM $DISTRO
# python3 shared with most images
RUN apk add --no-cache \
    python3 py3-pip git bash py3-multidict \
  && pip3 install --upgrade pip

# Shared layer between nginx, dovecot, postfix, postgresql, rspamd, unbound, rainloop, roundcube
RUN pip3 install socrate

# Image specific layers under this line
RUN apk add --no-cache ca-certificates openssl \
 && pip3 install requests

COPY --from=builder /fetchmail-7.0.0-alpha6/fetchmail /usr/local/bin
COPY fetchmail.py /fetchmail.py

RUN adduser -D fetchmail
RUN install -o fetchmail -g fetchmail -m 775 -d /run/fetchmail
USER fetchmail

CMD ["/fetchmail.py"]

HEALTHCHECK --interval=70s --timeout=10s --start-period=60s --retries=3 CMD test -f /run/fetchmail/fetchmail-dispatcher.pid && test `stat -c '%Y' /run/fetchmail/fetchmail-dispatcher.pid` -ge $(( `date +%s` - 600 )) && echo alive || exit 1
