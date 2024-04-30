FROM node:21-alpine as frontend_builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5000 

CMD npm run dev