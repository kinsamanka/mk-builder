# mk-builder:  Build Machinekit in Docker on Travis CI

The [Machinekit project][1] targets Debian Wheezy and Jessie, running
on `amd64`, `i386` and `armhf` architectures.  These Dockerfiles build
images for each combination of these Debian suites and CPU
architectures.

The Docker hub and Travis CI build environments only support x86
architectures and builds for `armhf` must be emulated in a chroot; for
uniformity, we also run x86 builds in a chroot.

The base container image common to all builds is a 64-bit Debian
Jessie Docker image built from the `mkdocker-base` directory.  On top
of this, container images for each `$SUITE-$ARCH` combination are
built from the top-level directory as separate Docker tags.  These
images each contain a chroot filesystem in `/opt/rootfs` with all
Machinekit build dependencies pre-installed.

To build the chroots on Docker hub and to run Machinekit builds within
them on Travis CI, we use [`proot`][2], a "user-space implementation
of `chroot`, `mount --bind`, and `binfmt_misc`", since `chroot` can
not work with the restricted privileges in the Docker hub and Travis
CI environments.

## How to build the images

The base image may already be available on Docker hub.  It may be
rebuilt with the `Dockerfile` in the `mkdocker-base` directory.

The final images are built from the top-level `Dockerfile`.  This git
repo contains one branch per `$SUITE-$ARCH` tag.  Any changes should
be committed to the `base` branch, and then propagated to the other
branches; these other branches are identical to `base` except for one
commit setting the `$SUITE` and `$ARCH` variables in the top-level
`Dockerfile`.  The `do-rebase.sh` script may help propagate these
changes.

For example, if you rebuild the base image tagged as
`jdoe/mk-builder:base`, rebuild the final images as follows:

	$ git checkout base  # always edit the 'base' branch
	$ $EDITOR Dockerfile # change top line-> 'FROM jdoe/mk-builder:base'
	$ git commit Dockerfile -m 'set base image'
	$ ./do-rebase.sh     # Warning!  Dangerous!

The `do-rebase.sh` script can be **dangerous!** Be sure you understand
what it does, or else propagate your changes to the other branches
manually.

The `do-rebase.sh` script should rebase the other branches on top of
your changes in the `base` branch.  Check the output of `git
show-branch`:  the `base` branch should be a common ancestor to all
other branches, which should each have exactly one more commit on top
labeled `set build to SUITE-ARCH`.

After this, build the container.  Build locally:

	$ git checkout jessie-64  # adjust branch as needed
	$ docker build -t jdoe/mk-builder:$(git rev-parse --abbrev-ref HEAD) .

Or build on the [Docker Registry][3] from your GitHub repo; push your
changes as follows and configure the build from the registry web
interface:

	$ git push --all -f  # DANGEROUS force-push all branches


[1]: http://machinekit.io
[2]: http://proot.me/
[3]: https://hub.docker.com
