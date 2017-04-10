## 0.1.13-pre

Bumped version for dev.

## 0.1.12

Cleaning up some work done in v0.1.11 to ensure that the project is again ready
for students.

## 0.1.11

 * Added a 404 as the fallback rule for the default handler. This means that
   anything other than `/` in the default handler is now a 404, the "hello
   world" message will only display for exactly `/`.
 * Added the solution to the day 3 lab. As I'm asking students to do this
   themselves, this specific implementation is for my own documentation purposes
   and also to add code that people can pull in if they are can't for some
   reason write this feature in themselves. This will be removed in the next
   release so that it's "hidden" from students until need be. If you are a
   student and reading the changelog, and can find the commit and add it that
   way, that is fine too - you are doing the work right. ;)

## 0.1.10

First release to Travis for lab 2.

## 0.1.9

This is nearly complete. Terraform fully deploys with builds triggered via "make
infrastructure", as do Docker container builds from "make release".

This is a version bump to test the automatic versioning that comes from the
build tooling, so that by simply making, we can:

 * Build the project with the new version number (0.1.9)
 * Create a new container for the version
 * Deploy that new container version to AWS via Travis

## 0.1.8

This release has new build automation features - namely a couple of shell
scripts that allow for the control of build tagging to support docker and
Terraform workflows via the automated setting of tags. It also formalizes the
Docker and Terraform deploy processes in a bid to bring the whole pipeline to
near completion.


## 0.1.7

Fixed release script in the way it was parsing CHANGELOG.md - the short-form
machine-readable format's logic was the other way around.

## 0.1.6

Bump version to test release script again, to make sure commit messages line
break properly.

## 0.1.5

Bumping version again to test release scripts.

## 0.1.4

Bump version (forgot to bump version before), working on testing out some
tagging and versioning automation code.

## v0.1.3

Fix the output so that it printed the right IP address thru XFF.

Also the TF code is now complete (save version locking the Rancher modules).
The deploy to AWS now succeeds.

## v0.1.2

Another release upload fix attempt.

## v0.1.1

Version bump to fix release upload.

## v0.1.0

Initial release.
