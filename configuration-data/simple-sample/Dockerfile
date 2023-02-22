FROM ubuntu 

LABEL maintainer="Hossein Yousefi <yousefi.hosein.o@gmail.com>"

RUN apt -y update && apt install -y apache2 apache2-utils &&\
 apt -y clean 

EXPOSE 8000
CMD ["apachectl", "-D", "FOREGROUND"]
