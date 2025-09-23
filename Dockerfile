# Use nginx for static HTML
FROM nginx:alpine

# Copy your HTML file
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Run nginx in foreground so container stays alive
CMD ["nginx", "-g", "daemon off;"]
