FROM alpine:3.7
RUN apk --update add postgresql-client python py-pip
RUN rm -rf /var/cache/apk/*
RUN pip install --upgrade awscli

WORKDIR /src
COPY backup.sh /src
RUN chmod +x /src/backup.sh

CMD /src/backup.sh