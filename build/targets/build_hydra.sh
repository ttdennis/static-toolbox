#!/bin/bash
set -e
set -x
set -o pipefail
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
source $GITHUB_WORKSPACE/build/lib.sh
init_lib "$1"

VERSION="v9.4"

build_hydra() {
    fetch "https://github.com/vanhauser-thc/thc-hydra" "${BUILD_DIRECTORY}/thc-hydra" git
    cd "${BUILD_DIRECTORY}/thc-hydra"
    git clean -fdx
    git checkout "$VERSION"
    CMD="CFLAGS=\"${GCC_OPTS}\" "
    CMD+="CXXFLAGS=\"${GXX_OPTS}\" "
    CMD+="LDFLAGS=\"-static -pthread\" "
    if [ "$CURRENT_ARCH" != "x86_64" ];then
        CMD+="CC_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc\" "
        CMD+="CPP_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-g++ -E\" "
        CMD+="CXX_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-g++\" "
    fi
    CMD+="./configure -DWITH_SSH1=On --host=$(get_host_triple)"
    eval "$CMD"
    make CFLAGS="-w ${GCC_OPTS}" LDFLAGS="-static -pthread" -j4
    strip "${BUILD_DIRECTORY}/thc-hydra/hydra"
}

main() {
    lib_build_openssl
    build_hydra
    local version
    version=$(get_version "${BUILD_DIRECTORY}/thc-hydra/hydra -v 2>&1 | head -n1 | awk '{print \$2}'")
    version_number=$(echo "$version" | cut -d"v" -f2)
    cp "${BUILD_DIRECTORY}/thc-hydra/hydra" "${OUTPUT_DIRECTORY}/hydra${version}"
    echo "[+] Finished building hydra ${CURRENT_ARCH}"

    echo "PACKAGED_NAME=hydra${version}" >> $GITHUB_OUTPUT
    echo "PACKAGED_NAME_PATH=${OUTPUT_DIRECTORY}/*" >> $GITHUB_OUTPUT
    echo "PACKAGED_VERSION=${version_number}" >> $GITHUB_OUTPUT
}

main
