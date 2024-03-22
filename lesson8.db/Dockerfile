# Build stage
FROM golang:alpine AS build
WORKDIR /go/src/app

COPY web.go .
RUN go env -w GO111MODULE=auto
RUN go build -o go_webserver .

# Final stage
FROM alpine
WORKDIR /app

# Copy only the built binary from the previous stage
COPY --from=build /go/src/app/go_webserver .

CMD ["./go_webserver"]
