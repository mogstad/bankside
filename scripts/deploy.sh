#!/bin/sh

set -e

TARGET_NAME="Bankside"
POD_SPEC="$TARGET_NAME.podspec.json"

InstallDeploymentDependencies() {
  brew install github-release
  brew install jq
}

ArchiveFramework() {
  carthage build --no-skip-current
  carthage archive $TARGET_NAME
}

PublishCocoaPods() {
  pod trunk push $POD_SPEC
}

Validate() {
  ValidateCocoaPodsSpec
}

ValidateCocoaPodsSpec() {
  echo "Validating version strings…"
  POD_VERSION=$(jq -r -c ".version" $POD_SPEC)
  GIT_TAG=$(jq -r -c ".source.tag" $POD_SPEC)
  if [[ $CIRCLE_TAG = "v$POD_VERSION" && $CIRCLE_TAG = $GIT_TAG ]]; then
    echo "CocoaPod spec valid, ready for deployment"
  else
    echo "CocoaPod version not updated, exiting"
    exit 0
  fi

  pod spec lint --quick
}

PublishGitHubRelease() {
  github-release release \
    --user $CIRCLE_PROJECT_USERNAME \
    --repo $CIRCLE_PROJECT_REPONAME \
    --tag $CIRCLE_TAG \
    --name "$TARGET_NAME ($CIRCLE_TAG)" \
    --description ""

  github-release upload \
    --user $CIRCLE_PROJECT_USERNAME \
    --repo $CIRCLE_PROJECT_REPONAME \
    --tag $CIRCLE_TAG \
    --name "$TARGET_NAME.framework.zip" \
    --file "./$TARGET_NAME.framework.zip"
}

InstallDeploymentDependencies
Validate
ArchiveFramework
PublishCocoaPods
PublishGitHubRelease
