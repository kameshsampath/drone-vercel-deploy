FROM node:lts-alpine
LABEL org.opencontainers.image.source https://github.com/kameshsampath/drone-vercel-plugin
LABEL org.opencontainers.image.authors="Kamesh Sampath<kamesh.sampath@hotmail.com>"

LABEL description="A Drone plugin deploy applications to vercel"

RUN apk -Uuv add bash curl ca-certificates jq

RUN npm i --location=global vercel

RUN adduser --system --uid 1001 -G root dev 

ADD run.sh /bin/
RUN chmod +x /bin/run.sh

USER dev

CMD ["/bin/run.sh"]