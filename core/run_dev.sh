#!/bin/bash

echo "Compiling tetrisnewsemailing..."

# Determine the architecture and set the binary name accordingly
ARCH=$(uname -m)
PLATFORMS="all"
if [[ "$ARCH" == "x86_64" ]]; then
    BINARY="tetrisnewsemailing-amd64"
    PLATFORMS="x86"
    echo "Detect x86_64 architecture, using amd64 binary"
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    BINARY="tetrisnewsemailing-arm64"
    PLATFORMS="arm"
    echo "Detect arm64/aarch64 architecture, using arm64 binary"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Using the alpine image to compile the Go application
docker exec p-g-alpine sh -c "cd /opt/core && sh ./go-build.sh $PLATFORMS"

echo "Copying tetrisnewsemailing to tetrisnewsemailing-core-tetrisnewsemailing-1 container..."

echo "Copying the compiled binary from p-g-alpine to tetrisnewsemailing-core-tetrisnewsemailing-1..."

# Copy the compiled binary to the tetrisnewsemailing-core-tetrisnewsemailing-1 container
docker cp $BINARY tetrisnewsemailing-core-tetrisnewsemailing-1:/opt/tetrisnewsemailing/core/tetrisnewsemailing


echo "Removing the public/dist/ directory from tetrisnewsemailing-core-tetrisnewsemailing-1 container..."

# Remove the public/dist/ directory from the tetrisnewsemailing-core-tetrisnewsemailing-1 container
docker exec tetrisnewsemailing-core-tetrisnewsemailing-1 sh -c "rm -rf /opt/tetrisnewsemailing/core/public/dist"


echo "Copying the public/ directory to tetrisnewsemailing-core-tetrisnewsemailing-1 container..."

# Copy the public directory to the tetrisnewsemailing-core-tetrisnewsemailing-1 container
docker cp public/. tetrisnewsemailing-core-tetrisnewsemailing-1:/opt/tetrisnewsemailing/core/public/


echo "Copying the manifest/ directory to tetrisnewsemailing-core-tetrisnewsemailing-1 container..."

# Copy the manifest/ directory to the tetrisnewsemailing-core-tetrisnewsemailing-1 container
docker cp manifest/. tetrisnewsemailing-core-tetrisnewsemailing-1:/opt/tetrisnewsemailing/core/manifest/


echo "Copying the template/ directory to tetrisnewsemailing-core-tetrisnewsemailing-1 container..."

# Copy the template/ directory to the tetrisnewsemailing-core-tetrisnewsemailing-1 container
docker cp template/. tetrisnewsemailing-core-tetrisnewsemailing-1:/opt/tetrisnewsemailing/core/template/


echo "Restarting tetrisnewsemailing-core-tetrisnewsemailing-1 container..."

# Restart the tetrisnewsemailing-core-tetrisnewsemailing-1 container to apply changes
docker restart tetrisnewsemailing-core-tetrisnewsemailing-1

echo "tetrisnewsemailing has been successfully compiled and deployed."