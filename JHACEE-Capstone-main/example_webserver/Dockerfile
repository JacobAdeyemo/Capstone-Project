FROM alpine:latest

ARG PORT=80
ARG UNAME=node

RUN apk add --update sqlite nodejs npm; \
    mkdir -p /srv/; \
    addgroup $UNAME; \
    adduser -S -h /home/$UNAME -G $UNAME $UNAME;

COPY . /srv/

WORKDIR /srv/

RUN rm -rf /srv/node_modules/; \
    npm install; \
    chown -R $UNAME: /srv/;

USER $UNAME

ENV PORT=$PORT
EXPOSE $PORT

CMD ["npm", "start"]
