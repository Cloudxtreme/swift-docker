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

RUN mkdir /etc/nginx/ssl
COPY ${RAILS_ENV}_cert.pem /etc/nginx/ssl/${DOMAIN_ROOT}_cert.pem
COPY ${RAILS_ENV}_key.pem /etc/nginx/ssl/${DOMAIN_ROOT}_key.pem
COPY ${RAILS_ENV}_chain.pem /etc/nginx/ssl/${DOMAIN_ROOT}_chain.pem

COPY create_config.rb /

RUN ruby /create_config.rb
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

CMD nginx