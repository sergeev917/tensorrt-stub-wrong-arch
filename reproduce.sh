#!/bin/bash
set -o errexit

dpkgdeb=$(
    command -v dpkg-deb ||
    echo "ERROR: dpkg package is not installed" 1>&2
)
ar=$(
    command -v ar ||
    echo "ERROR: binutils package is not installed" 1>&2
)
readelf=$(
    command -v readelf ||
    echo "ERROR: binutils package is not installed" 1>&2
)
if [[ -z "${dpkgdeb}" || -z "${ar}" || -z "${readelf}" ]]; then
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --repo-deb-path)
            if [[ "$#" -lt 2 ]]; then
                echo "ERROR: $1 option requires a value" 1>&2
                exit 1
            fi
            REPO_DEB_PATH="$2"
            shift 2
            ;;
        *)
            echo "ERROR: unknown option $1" 1>&2
            exit 1
            ;;
    esac
done
if [[ "${REPO_DEB_PATH+set}" != "set" ]]; then
    echo "ERROR: --repo-deb-path option is not set" 1>&2
    exit 1
fi
if [[ ! -r "${REPO_DEB_PATH}" ]]; then
    echo "ERROR: ${REPO_DEB_PATH} does not exist, not a file or bad perms" 1>&2
    exit 1
fi
CHECKSUM="$(dirname "${BASH_SOURCE[0]}")/CHECKSUM"
if ! sha256sum --check "${CHECKSUM}" < "${REPO_DEB_PATH}"; then
    echo "WARNING: checksum mismatch, results may vary" 1>&2
fi
workdir=$(mktemp --directory)
echo "INFO: unpacking into ${workdir}" 1>&2
"${dpkgdeb}" --extract "${REPO_DEB_PATH}" "${workdir}"
pkg=("${workdir}"/var/nv-tensorrt-local-*/libnvinfer-dev_*)
if [[ "${#pkg[@]}" == 0 ]]; then
    echo "ERROR: unable to find libnvinfer-dev package" 1>&2
    exit 1
fi
echo "INFO: unpacking ${pkg[0]} into ${workdir}" 1>&2
"${dpkgdeb}" --extract "${pkg[0]}" "${workdir}"
stub_path="${workdir}/usr/lib/aarch64-linux-gnu/stubs"
files=("${stub_path}"/*.a)
if [[ "${#files[@]}" == 0 ]]; then
    echo "ERROR: unable to find stub .a libraries in ${stub_path}" 1>&2
    exit 1
fi
for lib_path in "${files[@]}"; do
    objdir=${lib_path/.a/}
    mkdir --parents "${objdir}"
    "${ar}" x --output "${objdir}" "${lib_path}"
    find "${objdir}" -type f -name "*.o" -print0 |
    while read -d $'\0' objpath; do
        "${readelf}" --file-header "${objpath}" |
        sed -n "/Machine/s|.*:\s*|${objpath}   |p"
    done
done | grep --color=always 'Advanced Micro Devices X86-64\|$'
echo "All stubs are checked, unpacked files remain in ${workdir}!"
