# Use the official Node.js image as a base image
FROM node:alpine as build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install 

# Copy the rest of the application code
COPY . .

# Build the React app
RUN npm run build

# Use NGINX as a lightweight HTTP server to serve the static content
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

RUN rm -rf ./*
# Copy the built app from the previous stage
COPY --from=build /app/build .

# Copy custom Nginx configuration
# COPY nginx.conf .
 
# RUN systemctl reload nginx

# Expose port 80 to the outside world
EXPOSE 80

# Command to run NGINX
CMD ["nginx", "-g", "daemon off;"]

# Start the development server
#CMD ["npm", "start"]
