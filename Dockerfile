# FROM golang:1.19-alpine as builder
FROM harbor.nbfc.io/nbfc/golang:1.19-alpine as builder
COPY . /temp
WORKDIR /temp
RUN go mod tidy
RUN go mod vendor
RUN go build -ldflags="-extldflags=-static" main.go

# FROM alpine:latest
FROM harbor.nbfc.io/nbfc/alpine:latest
COPY --from=builder /temp/main /cosigntest
# ENTRYPOINT [ "/cosigntest" ]
CMD [ "/cosigntest" ]