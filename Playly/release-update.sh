VERSION=$1
GIT=$(command -v git)
REPO_DIR=/Users/max/Projects/Playly-landing

if [ ! "${VERSION}" ]; then
    echo "No version specified"
    exit
fi

create-dmg /Users/max/Library/Caches/AppCode2019.2/DerivedData/Playly-fflzgtzgwkhnjtalwlxeynmmtqlw/Build/Products/Release/Playly.app ${REPO_DIR}/versions/ --overwrite

echo "${VERSION}" > ${REPO_DIR}/versions/latest.txt
echo "window.latestVersion=${VERSION}" > ${REPO_DIR}/versions/latest.js

cd ${REPO_DIR}
${GIT} add --all .
${GIT} commit -m "New release ${VERSION}"
${GIT} push
