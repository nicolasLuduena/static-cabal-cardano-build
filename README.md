# Alpine Docker for GHC

This repository contains a Docker setup for building and pushing Docker images with multiple versions of the Glasgow Haskell Compiler (GHC) using Alpine Linux. This project takes inspiration from the [ghc-musl](https://github.com/utdemir/ghc-musl) repository.

## Overview

This project provides a Dockerfile and GitHub Actions workflow to build and push Docker images to the GitHub Container Registry. The images include various versions of GHC and are based on Alpine Linux.

## Usage

If inside one of this docker images, you will be able to run

```sh
cabal build all --enable-static-executable
```

It has some common Cardano dependencies such as libsodium, secp256k1 and blst.
