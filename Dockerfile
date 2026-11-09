# Stage 1: Build the Go application
FROM golang:1.25.1-alpine AS builder

WORKDIR /src

# Install Git and certificates for dependency downloads
RUN apk add --no-cache git ca-certificates

# Copy Go dependency files first for better Docker caching
COPY app/Server/MuchToDo/go.mod app/Server/MuchToDo/go.sum ./

RUN go mod download

# Copy the application source code
COPY app/Server/MuchToDo/ ./

# Build a small, statically linked Linux binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/muchtodo ./cmd/api


# Stage 2: Create the runtime image
FROM alpine:3.22

# Install certificates and wget for the health check
RUN apk add --no-cache ca-certificates wget \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only the compiled application
COPY --from=builder --chown=appuser:appgroup \
    /out/muchtodo /app/muchtodo

# Run as a non-root user
USER appuser

# Application port
EXPOSE 8080

# Check application health
HEALTHCHECK --interval=30s --timeout=5s \
    --start-period=20s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
    
CMD ["/app/muchtodo"]
