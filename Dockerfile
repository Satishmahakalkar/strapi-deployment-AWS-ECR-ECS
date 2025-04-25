FROM node:18

WORKDIR /app

COPY package*.json ./

# Install Python and build tools for native modules
RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    npm install

COPY . .

RUN npm rebuild better-sqlite3 --build-from-source

RUN npm run build

EXPOSE 1337

CMD ["npm", "start"]
