#!/bin/sh
# Generate documentation and deploy it to GitHub pages
# http://salesforce-ux.github.io/sass-deprecate/
sassdoc . sassdoc --config=.sassdocrc
git add sassdoc
git commit -m "Compile SassDoc"
git subtree push --prefix sassdoc origin gh-pages
