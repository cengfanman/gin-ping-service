# Use the official Go image as a base image
FROM golang:1.19 AS builder

# Set the current working directory inside the container
WORKDIR /app

# Copy the Go mod and sum files to the container
COPY go.mod go.sum ./

ENV GOPROXY=https://goproxy.cn,direct

# Download all dependencies. They will be cached if the go.mod and go.sum files are not changed 
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the application for a smaller and secured alpine-based image
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gin-ping-service .

### Start a new stage from scratch ###
FROM alpine:latest  

WORKDIR /root/

# Copy the pre-built binary from the previous stage
COPY --from=builder /app/gin-ping-service .

# Command to run the application
CMD ["./gin-ping-service"]
