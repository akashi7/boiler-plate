FROM node:20-bullseye-slim AS base
WORKDIR /usr/src/app

FROM base AS build
COPY package.json yarn.lock tsconfig.json ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

FROM base AS production
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/.env ./.env

CMD ["sh", "-c", " yarn build && npx typeorm migration:generate -d ./dist/src/__shared__/config/datasource.config.js src/_migrations/firstM  && npx typeorm migration:run -d ./dist/src/__shared__/config/datasource.config.js && node ./dist/src/main.js "]
