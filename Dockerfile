FROM golang:1.19-alpine as builder
RUN go mod tidy
RUN go mod vendor
RUN go build -ldflags="-extldflags=-static" main.go

FROM alpine:latest
COPY --from=builder /cosigntest /cosigntest

# ENTRYPOINT [ "/cosigntest" ]
CMD [ "/cosigntest" ]