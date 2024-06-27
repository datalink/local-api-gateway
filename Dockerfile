FROM node:18-alpine as base

FROM base as build

WORKDIR /app
COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM base as runtime

# Fake AWS credentials so that the Lambda client works
ENV AWS_ACCESS_KEY_ID='fake'
ENV AWS_SECRET_ACCESS_KEY='fake'

WORKDIR /app
COPY package.json package.json
RUN npm install --production
COPY --from=build /app/dist /app/dist

# To support mounted assets
WORKDIR /var/task

EXPOSE 8000
CMD ["node", "/app/dist/index.js"]
