FROM golang:1.16.3-alpine

ADD . /app
WORKDIR /app

RUN go build

CMD ["./run.sh"]
