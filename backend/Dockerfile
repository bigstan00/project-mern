# Use the official Node.js image as the base
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies on a clean slate
RUN npm ci  # Use npm ci for a clean install

# Install curl and stress-ng using apk (Alpine package manager)
RUN apk add --no-cache curl stress-ng

# Copy the rest of the application code into the container
COPY . .

# Expose the ports your app runs on
EXPOSE 3500

# Define environment variables
ENV PORT=3500
ENV DB_URL=mongodb+srv://sdakwoji:c7XLQAZPiRVVbure@cluster0.ojog0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0

# Run the application
CMD ["npm", "run", "start"]


#Health check for my container
HEALTHCHECK CMD curl --fail http://localhost:3500/ || exit 1
