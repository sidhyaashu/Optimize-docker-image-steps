# Stage 1: Builder
FROM node:20 AS builder

# Set working directory
WORKDIR /app

# Install dependencies only when needed
COPY package.json package-lock.json ./
RUN npm install --frozen-lockfile

# Copy application files
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript to JavaScript
RUN npm run build

# Stage 2: Production
FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy only production dependencies
COPY package.json package-lock.json ./
RUN npm install --production --frozen-lockfile

# Copy compiled JavaScript files from builder
COPY --from=builder /app/dist ./dist

# Copy other necessary files (e.g., .env)
COPY .env ./

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["node", "dist/index.js"]