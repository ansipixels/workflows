#! /bin/bash

SED="gsed"
if ! command -v $SED &> /dev/null
then
    echo "gsed could not be found, falling back to sed, might not work on macOS"
    SED="sed"
fi

# check template repository exists
if [ ! -d ../template ] ; then
  echo "Template repository not found. Please make sure it exists at ../template"
  exit 1
fi

set -x -e

cp -r ../template/.github ./
cp -i ../template/.gitignore ./

REPO_NAME=$(basename "$(pwd)")

# Api call to get the description of the repository:
REPO_DESC=$(gh api "repos/ansipixels/$REPO_NAME" -H "Accept: application/vnd.github+json" | jq -r '.description')

# Change NAME to $REPO_NAME in all files
# shellcheck disable=SC2046
$SED  -i -e "s/NAME/$REPO_NAME/g" -e "s/DESCRIPTION/$REPO_DESC/g" $(git ls-files) .github/workflows/*.yml

git add .github .gitignore
set +x
echo "Repository $REPO_NAME initialized with CI/CD configuration. (Description: $REPO_DESC)"
echo "Please review the changes, commit and push afterwards."
