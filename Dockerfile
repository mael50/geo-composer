# Stage 1: Base
FROM node:22-alpine AS base

# Set working directory
WORKDIR /app

# Enable pnpm if needed, or just use npm/yarn. 
# Since package-lock.json is present, we'll use npm.

# Stage 2: Build
FROM base AS build

# Copy package.json and package-lock.json first to leverage cache
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 3: Production
FROM base AS production

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3008
ENV HOST=0.0.0.0

# Copy the built output from the build stage
# Nuxt 4 (Nitro) outputs the production build to .output
COPY --from=build /app/.output ./.output

# Expose the port
EXPOSE 3008

# Start the application
CMD ["node", ".output/server/index.mjs"]
