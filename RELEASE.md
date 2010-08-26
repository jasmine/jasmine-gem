Releasing Jasmine

Add release notes here:
  http://wiki.github.com/pivotal/jasmine/release-notes

Jasmine core

* update version.json with new version
* rake jasmine:dist
* commit, tag, and push
* * git push
* * git tag -a x.x.x-release
* * git push --tags

Jasmine Gem

* rake jeweler:version:bump:(major/minor/patch)
* sudo rake jeweler:install and try stuff out
* * (jasmine init and script/generate jasmine)
* commit, tag, and push
* * git push
* * git tag -a x.x.x.x-release
* * git push --tags
* rake jeweler:release
* rake site
