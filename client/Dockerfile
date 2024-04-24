FROM node:21-alpine as frontend_builder

WORKDIR /app

COPY package*.json .

RUN npm install

COPY . .

FROM node:21-alpine

WORKDIR /app

COPY --from=frontend_builder /app .

EXPOSE 5000 

CMD npm run dev