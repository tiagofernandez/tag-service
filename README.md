# Tag Server

API server & web application.

## Development

### Local

Prerequisites:
- [Go](https://go.dev/doc/install)
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable)

```sh
# Install Air (live reload for Go apps).
curl -sSfL https://raw.githubusercontent.com/cosmtrek/air/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

# Download modules and install dependencies.
make install

# Run the API server.
make run-api

# Run the web application.
make run-web
```

### Docker

Prerequisites:
- [Docker](https://docs.docker.com/desktop/mac/install/)

```sh
# Build the Docker image.
make docker-image

# Run a detached container.
make docker-run

# Stop the detached container.
make docker-stop
```

### Kubernetes

Prerequisites:
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start#installation)
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [Skaffold](https://skaffold.dev/docs/install/)

```sh
# Create the kind cluster.
make k8s-cluster

# Run the Kubernetes application.
make k8s-dev
```
