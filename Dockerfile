FROM node:12.13.0-alpine 

WORKDIR /home/node/app

RUN chown -R node:node /home/node/app


COPY src/package*.json ./

USER node

RUN npm install

COPY --chown=node:node /src .

EXPOSE 8080

ENTRYPOINT ["node"]
CMD ["peer.js", "localhost:10000"]


