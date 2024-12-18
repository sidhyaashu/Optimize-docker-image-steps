To optimize your Docker image for a TypeScript and Express server, you need to ensure efficiency in building and running the container while minimizing its size and ensuring smooth operation. Here's an optimized approach:

### Optimized `Dockerfile`
```dockerfile
# Stage 1: Builder
FROM node:20 as builder

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
```

### Key Optimization Steps
1. **Multi-Stage Builds**:
   - The first stage (`builder`) installs dependencies and compiles TypeScript to JavaScript.
   - The second stage (`production`) creates a lightweight final image, copying only the production dependencies and the built files.

2. **Minimize Image Size**:
   - Use `node:20-slim` for the production stage to reduce the image size.
   - Copy only required files to the final image.

3. **Leverage `.dockerignore`**:
   - Prevent unnecessary files from being copied into the Docker build context:
     ```plaintext
     node_modules
     dist
     src
     .git
     .env
     *.log
     *.ts
     ```

4. **Install Dependencies Efficiently**:
   - Use `npm install --frozen-lockfile` to ensure consistency across environments.
   - Use `--production` in the final stage to install only the dependencies required for runtime.

5. **Environment Variables**:
   - Use `.env` for configuration and ensure it is listed in `.gitignore`.

6. **Expose Ports**:
   - Ensure the correct application port is exposed (`3000` in this case).

7. **Scripts**:
   - Add build and start scripts in your `package.json` for convenience:
     ```json
     {
       "scripts": {
         "build": "tsc",
         "start": "node dist/index.js"
       }
     }
     ```

### Steps to Build and Run
1. **Build the Docker Image**:
   ```bash
   docker build -t my-typescript-server .
   ```

2. **Run the Container**:
   ```bash
   docker run -p 3000:8000 --env-file .env my-typescript-server
   ```

### Additional Tips
- Use `ts-node` during development but build and run JavaScript files in production for better performance.
- Use a logging library like `winston` to monitor your application in production.
- Test your Docker image locally before deploying to production.