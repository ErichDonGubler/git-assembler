================================================================
git-assembler: update git branches using high-level instructions
================================================================

``git-assembler`` can perform automatic merge and rebase operations
following a simple declarative script.

It can be used to follow remote branches (such as pull requests)
conveniently, test multiple patches together, work on interdependent
feature branches easily while waiting for upstream and so on...

.. contents::


Motivation
==========

TODO


Quickstart
==========

Basic setup
-----------

Copy ``git-assembler`` into $PATH::

  git clone https://gitlab.com/wavexx/git-assembler
  cd git-assembler/
  sudo cp git-assembler /usr/local/bin

Configure git::

  git config --global alias.as assembler
  git config --global rerere.enable true

``git-assembler`` can now be invoked as::

  git as

Without any argument, ``git as`` is a no-op and will show the current
assembly status graph as defined from the ``.git/assembly`` file.


Automating merges
-----------------

Scenario: You have a "fixes" branch created off a release which is for
release-critical fixes. You want to merge "fixes" back to "master" every
time "fixes" is updated.

Create a test repository::

  # new repo
  git init
  # add a file/commit
  touch file
  git add file
  git commit
  # create a "fixes" branch with a new commit
  git checkout -b fixes
  echo "test" > file
  git commit -a

To declare that "master" needs to be kept up-to-date by merging back
"fixes" every time it is updated, create ``.git/assembly`` with the
following content::

  merge master fixes

You can run ``git as --dry-run`` to display what ``git-assembler`` will
do to update the repository::

  $ git as -n
  git-assembler: merging fixes into master

To show the current status in a graph, run ``git as`` with no flags::

  $ git as
  master
    >fixes

"master" is shown followed with an indented list of branches to be
merged. In this case only "fixes" is listed. "master" is also shown in
bold, meaning that it's out of date. "fixes" is displayed in green to
indicate that it contains updated content. The leading ">" indicates
that it's also the current branch.

To actually perform the merge, use the ``--assemble`` flag explicitly
as shown here in short form with verbose output::

  $ git as -av
  git-assembler: merging fixes into master
  git-assembler: restoring initial branch fixes


Following remote branches
-------------------------

Scenario: You're following a project "coolthing" with multiple forks.
There are two PRs ("feature" from "user1" and "bugfixes" from "user2")
that interest you and want to merge both into your own fork. Both
"user1" and "user2" as well as upstream play nice, and do not rebase
their branches.

Clone the original project::

  git clone https://github.com/coolthing/coolthing.git
  cd coolthing

Add the two PRs, by adding the two remotes and fetching the respective
branches::

  git remote add user1 "https://github.com/user1/coolthing.git"
  git fetch user1 feature
  git remote add user2 "https://github.com/user2/coolthing.git"
  git fetch user2 bugfixes

Any valid ref name is allowed in ``.git/assembly``, so we can directly
reference them for any merge operation::

  merge master origin/master
  merge master user1/feature
  merge master user2/bugfixes

Display the current status::

  $ git as
  >master
    origin/master
    user1/feature
    user2/bugfixes

By reading the graph, we see "master" is the current branch and is
out-of-date (shown in bold). "master" has three branches which are
merged into it. "origin/master" is in sync (we just cloned from it), but
"user1/feature" and "user2/bugfixes" (shown in green) have more recent
commits that need to be merged back into "master".

To perform the merges as needed use ``git as -a``.

To update your repository in the future you just need to fetch all
remotes and *then* call ``git as -a`` to merge all changes into
"master". It's usually convenient to display the current status with
``git as`` just prior to assembling::

  git fetch --all
  git as
  git as -a

It's useless to call ``git pull`` in this scenario since
``git-assembler`` will do the same while also showing a more
comprehensive repository status *before* performing the required merges.

This is also entirely optional: you can skip
``merge master origin/master`` in the assembly file and use ``git pull``
as usual, although in this case you still have to fetch the additional
remotes manually in order to see/use all available updates with
``git as`` (essentially doing the same, but with more commands).


Rebasing local branches
-----------------------

TODO


Testing two branches together
-----------------------------

TODO


PRs with unresponsive upstream
------------------------------

TODO


Assembly graph
==============

TODO


Assembly file reference
=======================

Location
--------

The assembly file is searched in the following order::

 $GIT_DIR/.git/assembly
 $GIT_DIR/.gitassembly

``.git/assembly`` is local and overrides a possibly versioned
``.gitassembly``. The location can be overridden on the command line
through the ``--config`` flag.


Syntax
------

Empty lines, and lines starting with "#" are ignored. Leading and
trailing whitespace is also ignored, allowing both commands and comments
to be indented. Each commands starts on it's own line.

Commands that define a target branch type (``base``, ``stage``,
``rebase``) cannot be specified more than once.


Commands
--------

target
~~~~~~

:Syntax: ``target branch [branch...]``
:Description:
   Set the default target branch (or branches) to operate on when no
   explicit branch is given on the command line. When no target is
   specified, all defined branches are checked for updates. Use
   ``--all`` on the command line to override the default target.
   ``target`` can be specified only once.

base
~~~~

:Syntax: ``base branch-name base-name``
:Description:
   Define ``branch-name`` to be a "regular" branch which can be
   optionally bootstrapped from ``base-name``. If ``branch-name``
   doesn't exist and ``--create`` is specified on the command line then
   ``branch-name`` is forked off ``base-name``. When ``--recreate`` is
   given, ``branch-name`` is deleted and recreated, discarding any
   existing commit.

stage
~~~~~

:Syntax: ``stage branch-name base-name``
:Description:
   Define ``branch-name`` to be a "staging" branch which is deleted and
   recreated by forking off ``base-name`` every time any of its
   dependencies (base or merged branches) is updated.

rebase
~~~~~~

:Syntax: ``rebase branch-name base-name``
:Description:
   Define ``branch-name`` to be a "rebased" branch. Rebase
   ``branch-name`` on top of ``base-name`` every time ``base-name`` is
   updated.

merge
~~~~~

:Syntax: ``merge target branch [branch...]``
:Description:
   Merge ``branch`` into ``target`` every time ``branch`` is updated.
   Multiple branches to merge can be given on the same command.
   ``merge`` can be repeated to specify more branches on multiple lines.
   The merge order follows the declaration order.


Git configuration
=================

Once ``git-assembler`` is installed, it can be called as a regular git
sub-command::

  git assembler

We recommend to define a shorter global alias::

  git config --global alias.as assembler

which allows to use ``git-assembler`` using just::

  git as

Since ``git-assembler`` can be instructed to perform the same merge and
rebase operations over and over, it is recommended to enable ``rerere``
in each repository where ``git-assembler`` is being used::

  # enable in the current repository
  git config rerere.enable true

  # enable for all repositories
  git config --global rerere.enable true

Good familiarity with `git-rerere(1)
<https://git-scm.com/docs/git-rerere>`_ is recommended.

Ensure the git ``reflog`` (``core.logAllRefUpdates``) has not been
disabled. It is essential for the correct operation of complex rebase
operations.


Authors and Copyright
=====================

| Copyright(c) 2019-2020 by wave++ "Yuri D'Elia" <wavexx@thregr.org>
| Distributed under the GNU GPLv3+ license, WITHOUT ANY WARRANTY.

``git-assembler``'s GIT repository is publicly accessible at:

https://gitlab.com/wavexx/git-assembler
