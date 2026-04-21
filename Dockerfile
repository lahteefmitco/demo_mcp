FROM node:22-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production
# Default for local `docker run -p 8080:8080`. Cloud Run injects PORT at runtime and overrides this.
ENV PORT=8080

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY src ./src

RUN chown -R node:node /app

USER node

CMD ["npm", "run", "start"]
