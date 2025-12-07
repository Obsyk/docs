# Copyright (c) Obsyk. All rights reserved.
# Proprietary and confidential.

FROM nginx:1.27-alpine

# Copy built docs to nginx html directory
COPY site/ /usr/share/nginx/html/

# Custom nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
