FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf
# NB : on va preférer monter les volumes pour ces fichiers depuis le host afin de ne pas inclure de secret
# directement dans une image qu'on peut potentiellement pousser sur un docker hub public ou non (toujours analysable...)
# COPY certs/ /etc/nginx/certs/
# COPY .htpasswd /etc/nginx/.htpasswd

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]