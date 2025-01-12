# Use an official Node.js image
FROM node:16

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build the application
RUN npm run build

# Specify the command to run the app
CMD ["node", "dist/index.js"]

# Expose the port (if the application uses any HTTP server, e.g., in future extensions)
EXPOSE 3000