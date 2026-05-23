ARG NGINX_IMAGE=nginx:1.27-alpine

FROM ${NGINX_IMAGE}

ENV SUB2API_BACKEND=http://host.docker.internal:8080
ENV CLIENT_MAX_BODY_SIZE=100m

COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY dist /usr/share/nginx/html

EXPOSE 80
