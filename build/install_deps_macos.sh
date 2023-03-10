#!/bin/sh
brew install \
    liblinear \
    libssh2 \
    lua \
    openssl@1.1 \
    pcre

# install GNU tools
brew install gnu-sed --with-default-names
which sed