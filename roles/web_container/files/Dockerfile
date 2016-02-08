FROM ubuntu

ARG RAILS_ENV=development
ARG DOMAIN_ROOT
ARG APP_CONFIG

ENV APP_CONFIG $APP_CONFIG
ENV DOMAIN_ROOT=$DOMAIN_ROOT
ENV RAILS_ENV=$RAILS_ENV

RUN /bin/bash -c " \
  mkdir /var/apps ;\
  apt-get update ;\
  apt-get install -y nginx ruby ;\
"

COPY create_config.rb /

RUN ruby /create_config.rb
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

CMD nginx