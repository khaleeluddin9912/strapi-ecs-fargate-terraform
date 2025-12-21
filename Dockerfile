FROM node:20-alpine

# Install required dependencies INCLUDING PostgreSQL
RUN apk add --no-cache python3 make g++ libc6-compat postgresql-client postgresql-dev

WORKDIR /app

COPY package*.json ./

# Install all dependencies including pg from package.json
RUN npm install

COPY strapi/ ./
RUN npm run build

EXPOSE 1337
CMD ["npm", "start"]