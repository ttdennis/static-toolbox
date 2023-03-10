#!/bin/sh
brew install \
    liblinear \
    libssh2 \
    lua \
    openssl@1.1 \
    pcre

# install GNU tools
brew install --default-names gnu-sed
which sed