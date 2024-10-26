# # Stage 1: Build the React app
# FROM node:alpine as build_image

# # Set working directory
# WORKDIR /home/app

# # Copy package.json and package-lock.json first (for efficient caching)
# COPY package.json package-lock.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the source code
# COPY . .

# # Build the application
# RUN npm run build

# # Stage 2: Production container
# FROM node:alpine as prod_build

# # Set working directory
# WORKDIR /home/app

# # Copy build files from the previous stage
# COPY --from=build_image /home/app/build/ /home/app/build/

# # Copy node_modules from the build stage to the production stage
# COPY --from=build_image /home/app/node_modules/ /home/app/node_modules/

# # Optionally expose port (React apps typically serve on port 3000)
# EXPOSE 3000

# # Set the command to serve the built app
# CMD ["npx", "serve", "-s", "build", "-l", "3000"]


# Stage 1: Build the React app
FROM node:16-alpine as build_image

# Set working directory
WORKDIR /home/app

# Install curl and stress-ng using apk (Alpine package manager)
RUN apk add --no-cache curl

# Copy package.json and package-lock.json first (for efficient caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production container
FROM node:16-alpine as prod_build

# Set working directory
WORKDIR /home/app

# Copy build files from the previous stage
COPY --from=build_image /home/app/build/ /home/app/build/

# Optionally expose port (React apps typically serve on port 3000)
EXPOSE 3000

# Set the command to serve the built app
CMD ["npx", "serve", "-s", "build", "-l", "3000"]
