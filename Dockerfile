# start from the official go image with version 1.23
FROM golang:1.23 as builder

# set the working directory inside the container
WORKDIR /app

# copy the go.mod and go.sum files to the working directory
# these files define the project dependencies
COPY go.mod go.sum ./

# download all the dependencies specified in go.mod and go.sum
RUN go mod download

# copy the entire current directory contents into the container
COPY . .

# build the go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./server/main.go

# start a new build stage from the Alpine Linux image
# this will be the final smaller image that will run the application
FROM alpine:latest

# install ca certificates, often necessary for HTTPS requests
RUN apk --no-cache add ca-certificates

# set the working directory to /app/
WORKDIR /app

# copy the binary from the previous stage
COPY --from=builder /app/main .

# copy over the static assets
COPY public/ /app/public/

# expose the port
EXPOSE 8080

# prevent the executable from being wrapped in a shell, reducing startup time
# and signal handling issues. execute from /app/main
CMD ["/app/main"]
