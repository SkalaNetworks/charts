#!/bin/bash

set -ex

ORG=${ORG:-kubeovn}  # GitHub organization
REPO="repository/"    # Folder in which we keep the charts

usage() {
    >&2 echo "Usage: $0 <project> <version>"
    >&2 echo
    >&2 echo "Example: $0 kube-ovn v1.14.0"
}

main() {
    PROJECT="$1"
    VERSION="$2"

    # Check we are releasing a known project of the Kube-OVN organization
    if [ "$PROJECT" != kube-ovn ] ; then
        echo "Project $PROJECT is invalid"
        usage
        exit 1
    fi

    # Clone the project at the specific branch/tag so we can retrieve the chart
    git clone --depth 1 --branch "$VERSION" "https://github.com/${ORG}/${PROJECT}.git"

    if [ "$PROJECT" == kube-ovn ]; then
	CHART_DIR="charts/kube-ovn-v2"
    fi

    # Generate the chart's TGZ, move it to the repository folder
    helm package --version ${VERSION} ${PROJECT}/${CHART_DIR}
    mv ${PROJECT}-${VERSION}.tgz ${REPO}

    # Update the repository endex 
    helm repo index ${REPO}
}

main "$@"
