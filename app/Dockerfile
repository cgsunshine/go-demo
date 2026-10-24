FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY main.go .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/app main.go

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=builder /out/app /app
ENV APP_VERSION=v1
EXPOSE 8080
ENTRYPOINT ["/app"]