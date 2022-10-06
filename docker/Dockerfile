FROM node:lts-alpine
LABEL org.opencontainers.image.source https://github.com/kameshsampath/drone-vercel-deploy
LABEL org.opencontainers.image.authors="Kamesh Sampath<kamesh.sampath@hotmail.com>"

LABEL description="A Drone plugin deploy applications to vercel"

RUN apk -Uuv add bash curl ca-certificates jq

RUN npm i --location=global vercel

ADD run.sh /bin/
RUN chmod +x /bin/run.sh

USER node

CMD ["/bin/run.sh"]