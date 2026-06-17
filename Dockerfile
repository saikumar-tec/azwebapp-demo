# --- Stage 1: Build & Dependency Installation ---
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci

# Copy the rest of your application code
COPY . .

# Run build step if you use TypeScript, Next.js, or React (uncomment if needed)
# RUN npm run build

# Remove development dependencies to keep production image small
RUN npm prune --production


# --- Stage 2: Final Production Runtime ---
FROM node:20-alpine AS runner
WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Copy only the necessary runtime files from the builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/. . 

# Expose the port your application listens on (change 3000 if your app uses a different port)
EXPOSE 3000

# Run the app using node directly (avoid npm run to handle OS signals correctly)
CMD ["node", "index.js"]
