# Use official Node.js image as the base image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build Nuxt.js application for production
RUN npm run generate

# Expose port 5050
EXPOSE 5050

# Command to run the application
CMD ["npm", "start"]