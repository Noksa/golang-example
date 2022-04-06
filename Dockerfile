ARG DOCKER_REPOSITORY
FROM --platform=${BUILDPLATFORM} ${DOCKER_REPOSITORY}/3rdparty/golang:1.18.0-alpine3.15 as builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /workspace
RUN apk add --no-cache bash
SHELL [ "/bin/bash", "-c" ]
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download
# Copy the go source
COPY . .

# Build
RUN CGO_ENABLED=0 go build -o golang-example

FROM ${DOCKER_REPOSITORY}/3rdparty/alpine:3.15 as final
ARG TARGETOS
ARG TARGETARCH
COPY --from=builder /workspace/oobit_${TARGETOS}_${TARGETARCH}_* ./oobit
COPY --from=builder /workspace/oobithelper ./oobithelper
CMD [ "/golang-example" ]


FROM scratch as export
COPY --from=builder /workspace/* .