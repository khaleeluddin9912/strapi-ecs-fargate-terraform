FROM node:20-alpine

RUN apk add --no-cache python3 make g++ libc6-compat

WORKDIR /app

COPY strapi/package*.json ./
RUN npm install

COPY strapi/ ./
RUN npm run build

EXPOSE 1337
CMD ["npm", "start"]
