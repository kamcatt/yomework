FROM alpine

RUN apk update
RUN apk add nginx
RUN mkdir -p /run/nginx
RUN chown -R nginx:nginx /run/nginx
RUN chmod 775 /run/nginx
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]