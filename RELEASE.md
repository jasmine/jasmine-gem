Releasing Jasmine

Add release notes here:
  http://wiki.github.com/pivotal/jasmine/release-notes

Jasmine core

* update version.json with new version
* sudo gem install ragaskar-jsdoc_helper
* rake jasmine:dist
* commit, tag, and push
** git push
** git tag -a x.x.x-release
** git push --tags
** upload lib/jasmine-x.x.x.js to github

Jasmine Gem
* rake jeweler:version:bump:major/minor/patch
* sudo rake jeweler:install and try stuff out
** (jasmine init and script/generate jasmine) 
* commit, tag, and push
** git push
** git tag -a x.x.x.x-release
** git push --tags
* rake jeweler:release
