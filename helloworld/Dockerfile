FROM golang:1.17-alpine

WORKDIR /go
ADD . /go
RUN cd /go && go build main.go
EXPOSE 9527
