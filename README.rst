================================================================
git-assembler: update git branches using high-level instructions
================================================================

``git-assembler`` can perform automatic merge and rebase operations
following a simple declarative script. Like "make", for branches.

It can be used to follow remote branches (such as pull requests)
conveniently, test multiple patches together, work on interdependent
feature branches more easily, and so on...

.. contents::


Motivation
==========

When working with git it's often convenient/necessary to split
development into separate branches, where each branch contains a
logically independent set of changes. As time progresses though it's not
uncommon to work on several feature and bugfix branches at the same
time, often long-lived, and with dependent or downright conflicting
changes.

Managing such changes, keeping them separate and evolving them can
become tedious and time consuming.

As an example, imagine working on a new feature on its own dedicated
branch until a critical API is found to be missing, or broken. Policy
dictates that such change needs a separate fix, so you split-off
development into a dedicated branch and submit the change for testing.
Meanwhile you go back to the feature branch, merge the fix, and
continue. But the fix turns out to be incomplete a few days later, so
you go back, commit, switch back and merge. At least once or twice more.

If that sounds familiar, and you'd like some automation, then a tool
such as topgit_ or ``git-assembler`` might fit the bill. The major
difference between the two is that ``topgit`` enforces a minimal
workflow to preserve development history, while ``git-assembler`` just
gives you the tools which *could* be used to implement such workflow,
but enforces absolutely nothing.

.. _topgit: https://github.com/mackyle/topgit


Quickstart
==========

Basic setup
-----------

You'll need Python 3 and a recent version of Git.

Copy ``git-assembler`` into $PATH::

  git clone https://gitlab.com/wavexx/git-assembler
  cd git-assembler/
  sudo cp git-assembler /usr/local/bin

Configure git::

  git config --global alias.as assembler

``git-assembler`` can now be invoked as::

  git as

Without any argument, ``git as`` is a no-op and will show the current
assembly status graph as defined from the ``.git/assembly`` file.


Automating simple merges
------------------------

Scenario: You have a "fixes" branch which is where production bugs get
fixed. You want to merge all "fixes" back to "master" unconditionally.

Create a test repository::

  # a repository with a master branch
  git init
  touch file
  git add file
  git commit
  # create a "fixes" branch with a new commit
  git checkout -b fixes
  echo "test" > file
  git commit -a

Create ``.git/assembly`` with the following content::

  merge master fixes

You can run ``git as --dry-run`` to display what ``git-assembler`` will
do to update the repository::

  $ git as --dry-run
  git-assembler: merging fixes into master

To show the current status in a graph, run ``git as`` with no flags::

  $ git as
  master
    >fixes

"master" is shown followed with an indented list of branches to be
merged (in this case only "fixes"). "master" is also shown in bold,
meaning that it's out of date. "fixes" is displayed in green to indicate
that it contains updated content. The leading ">" indicates that it's
also the current branch.

To actually perform the merge use the ``--assemble``/``-a`` flag
explicitly::

  $ git as --assemble --verbose
  git-assembler: merging fixes into master
  git-assembler: restoring initial branch fixes


Following remote branches
-------------------------

Scenario: You're following a project "coolthing" with multiple forks.
There are two PRs ("feature" from "user1" and "bugfixes" from "user2")
that interest you and want to always merge both into your own fork.

Clone the original project::

  git clone https://github.com/coolthing/coolthing.git
  cd coolthing/

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

In this graph we see "master" is the current branch and is out-of-date
(shown in bold). "master" has three branches which are merged into it.
"origin/master" is in sync (we just cloned from it), but "user1/feature"
and "user2/bugfixes" (shown in green) have more recent commits that need
to be merged.

Use ``git as --dry-run`` (or ``-n`` in short) to see that broken down::

  $ git as -n
  git-assembler: merging user1/feature into master
  git-assembler: merging user2/bugfixes into master

To perform the merges use ``git as -a``.

To update your repository in the future you just need to fetch all
remotes and then call ``git as -a``. It's usually convenient to display
the current status with ``git as`` just prior to assembling::

  # update from all sources
  git fetch --all
  # inspect the status
  git as
  # perform updates
  git as -a

It's useless to call ``git pull`` in this scenario since
``git-assembler`` will do the same while also showing a more
comprehensive repository status *before* performing the required merges.
It isn't forbidden though, and combining ``git pull`` with ``git as``
works just as well (it just takes more commands).


Rebasing local branches
-----------------------

Scenario: You're working on two independent feature branches ("feature1"
and "feature2") and want to keep both always rebased on "master" during
development.

Create the following ``.git/assembly``::

  rebase feature1 master
  rebase feature2 master

The respective graph::

  $ git as
  feature1 <- master
  feature2 <- master

The left arrow indicates that "feature1" is based on top of "master".

Whenever master is updated (via ``git pull``, for example), "master"
will turn green to indicate new content, while both "feature1" and
"feature2" become bold to indicate that they will be updated.

Running ``git as`` will rebase both in one shot, irregardless of the
current branch::

  $ git as -v
  git-assembler: rebasing feature1 onto master
  git-assembler: rebasing feature2 onto master


Testing two branches together
-----------------------------

Scenario: You're working on branch "feature", but require "bugfix" for
testing. You want to keep them logically separated, but still perform
tests easily.

We can define a staging branch "test" with the following
``.git/assembly``::

  stage test feature
  merge test bugfix

A `stage` branch is recreated from scratch whenever it's base or any of
its merged branches is updated.

Resulting graph::

  $ git as
  test <= feature
    bugfix

The left double arrow indicates that "test" is staged on top of
"feature". As seen before, it's followed by a list of indented branches
to merge: "bugfix".

Whenever either "bugfix" or "feature" is updated, "test" is deleted and
recreated first by branching off "feature" and then merging "bugfix"::

  $ git as -av
  git-assembler: erasing existing branch test
  git-assembler: creating branch test from feature
  git-assembler: merging bugfix into test

Staging branches can be helpful also to ensure that branches merge
cleanly.


Invocation and usage
====================

Command line
------------

``git-assembler`` is best used with a short git alias (see `Basic
setup`_ and `Recommendations`_ for extra details).

The suggested shorthand ``git as`` needs to be run within a git
repository. The primary location of the configuration file is
``.git/assembly``. Such file contains instructions on how to update any
defined branches by performing merge or rebase operations. A complete
list of commands is available in `Assembly file reference`_.

By default, without any arguments, ``git-assembler`` reads the assembly
file and displays a graph representation of the defined branches without
performing any action::

  $ cat .git/assembly
  merge master test
  $ git as
  master
    test

The graph layout is documented in `Assembly graph reference`_.

The ``--dry-run``/``-n`` flag displays instead a flattened list of
operations to be performed, in order, on the current repository::

  $ git as --dry-run
  git-assembler: merging test into master

To actually perform the operations the ``--assemble``/``-a`` flag is
*always* required. This is true also for the ``--create`` or
``--recreate`` flags. This can be seen in conjunction with
``--dry-run``::

  $ cat .git/assembly
  base new master
  merge new bugfix
  $ git as --dry-run
  git-assembler: branch new needs creation from master
  $ git as --dry-run --create
  git-assembler: creating branch new from master
  git-assembler: merging bugfix into new

By default *all* defined branches are either displayed or updated. A
list of explicit targets can be given on the command line::

  $ cat .git/assembly
  merge branch1 a b
  merge branch2 c
  $ git as
  branch1
    a
    b
  branch2
    c
  $ git as branch2
  branch2
    c
  $ git as -av branch2
  git-assembler: merging c into branch2

When working on large projects the list of default targets can be
overridden in the assembly file. Non-existent branches are ignored
unless they are depended-on by one of the requested targets. Branches
which exist, but are not defined, are also ignored.


Handling conflicts
------------------

There's no magic introduced by ``git-assembler`` involving conflicts.

When conflicts arise in a merge operation ``git-assembler`` will drop
you into the branch which is being merged onto. Assuming a simple
merge conflict::

  $ cat .git/assembly
  merge master branch1
  $ git as -av
  git-assembler: merging branch1 into master
  Auto-merging test
  CONFLICT (content): Merge conflict in test
  Recorded preimage for 'test'
  Automatic merge failed; fix conflicts and then commit the result.
  U       test
  git-assembler: error while merging branch1 into master
  git-assembler: stopping at branch master, fix/commit then re-run git-assembler

Use ``git add/commit`` as usual to resolve the conflict, or
``git merge --abort`` to cancel the merge. Aborting the merge can be
useful, for example, to invoke a different merge strategy or to remove
the offending rule and disregard the merge completely.

As soon as the merge is resolved or aborted, state is instantly
reflected into ``git as``::

  # fix the merge
  $ git commit
  $ git as -av
  git-assembler: already up to date

Of course, if the merge is aborted but the `merge` rule is not removed,
``git as`` will simply try again on the next invocation.

Additional information is displayed when two or more branches are
involved in the current run::

  $ cat .git/assembly
  merge master branch1
  merge branch1 branch2
  $ git as
  >master
    branch1
      branch2
  $ git as -av
  git-assembler: merging branch2 into branch1
  Auto-merging test
  CONFLICT (content): Merge conflict in test
  Recorded preimage for 'test'
  Automatic merge failed; fix conflicts and then commit the result.
  U       test
  git-assembler: error while merging branch2 into branch1
  git-assembler: stopping at branch branch1, fix/commit then re-run git-assembler

"master" will be adorned in the graph to indicate that it was the
initial branch when ``git as`` was started (note the ``*`` after the
name), while the current branch you're now on is "branch1"::

  $ git as
  master*
    >branch1
      branch2

After fixing the merge, running ``git as -av`` a second time will
continue and restore the initial branch::

  # fix conflict
  $ git commit
  $ git as -av
  git-assembler: merging branch1 into master
  git-assembler: restoring initial branch master

Conflicts arising during a rebase operation drop you on the branch which
is being rebased and work exactly the same: just fix the conflict and
either ``rebase --continue`` or ``rebase --abort`` as you normally
would.

The situation gets more complex when `stage` (and, to a lesser extent,
`base`) is involved somewhere in the graph.

Since staging branches will be deleted and re-created at every update,
the same merge conflicts will keep repeating unless the conflict is
handled within the branch being merged itself, which is not always
desired.

In these situations git-rerere_ is required (see `Recommendations`_).

The basic gist of ``rerere`` is that, once enabled, will record how the
conflict was resolved and apply the same solution whenever it happens
again. This allows the same merge operation to repeat successfully.

``git as`` applies merges in a deterministic order (the declaration
order) in order to let you control and maximize the chances of a
successful and reproducible resolution. ``git as`` will additionally
auto-commit a successful ``rerere`` solution so that the operation can
continue without manual intervention in most cases.

``git rerere`` might lead to surprising (and sometimes broken) results
during conflict resolution, which is the main reason it's not enabled by
default. Reading ``rerere``'s own documentation and experimenting on a
toy repository is highly encouraged before starting to use staging
branches.


General usage advice
--------------------

The ``.git/assembly`` file is not set in stone. Change and adapt your
rules to whatever makes you work better. I adapt my rules according to
what branches I'm working on and remove them when I'm done.

Also, just because you can rebase everything, it doesn't mean you
should. Pushed-state aside, you can still work with plain merges and
rebase just once for cleanup. Or mix the two methods by intervening
manually.

In contrast to other similar tools, ``git-assembler`` is stateless and
doesn't care what you do or did to get to the current repository state.

Not all branch layouts that can be defined with ``git-assembler`` make
sense (or work at all).


Advanced topics
===============

Testing branches: continuous integration
----------------------------------------

Scenario: You have a "feature" branch and you want to keep an ephemeral
branch "test" where changes from both mainline and the feature branch
are continuously merged. Using `stage` would work, but cause the work
tree to change and rebuild too frequently. You need something more
efficient.

A simple and perfectly valid approach would be to just create a
throw-away branch and use `merge`::

  git checkout -b test master

``.git/assembly``::

  merge test master feature

You can more conveniently mark that "test" can be bootstrapped from
"master" using the `base` command::

  base test master
  merge test master feature

The graph shows::

  $ git as
  test .. master
    master
    feature

The ".." notation indicates that "test" is initially based off "master".
Also, the first time ``git as`` is run, "test" is highlighted in red to
indicate that the branch doesn't exist. "base" branches are not
initialized unless ``--create`` is given on the command line::

  $ git as -av
  git-assembler: branch test needs creation from master
  $ git as -avc
  git-assembler: creating branch test from master
  git-assembler: merging master into test
  git-assembler: merging feature into test
  git-assembler: restoring initial branch master

Any subsequent update would simply perform the merge operations as
needed. But, because "base" branches are intended to be *ephemeral*,
they can also be explicitly re-initialized to discard any branch history
and start anew by using ``--recreate``::

  $ git as -av --recreate
  git-assembler: erasing existing branch test
  git-assembler: creating branch test from master
  git-assembler: merging master into test
  git-assembler: merging feature into test
  git-assembler: restoring initial branch master

Base branches behave otherwise like a normal branch: if you want to
update from the starting branch you have to do so explicitly, as done
above.


Feature and bugfix: a rebase approach
-------------------------------------

Scenario: You're working on branch "feature", but require "bugfix" to
continue development, as well as recent changes from "master" ("bugfix"
is too old, and is still in development). You want to keep "feature"'s
history clean during development, before it's being pushed.

We can use an intermediate branch with both master and "bugfix" applied.
Then rebase our "feature" branch on top of it::

  base temp master
  merge temp master
  merge temp bugfix
  rebase feature temp

The resulting graph::

  feature <- [temp]
  temp .. master
    master
    bugfix

This is efficient, but what if "bugfix" inadvertently gets rebased?
Bootstrap the "temp" branch again, using ``git as -a --recreate``.

If "bugfix" happens to rebase frequently then a staging branch can get
more verbose (requiring ``rerere`` to be active), but will keep on
working::

  stage temp master
  merge temp bugfix
  rebase feature temp

The graph is similar::

  feature <- [temp]
  temp <= master
    bugfix

Once bugfix is applied, we can just discard our temporary branch and
rebase on "master".


Assembly graph reference
========================

Layout
------

The graph takes the following core structure::

   branch bases
     dependencies

The branch if followed on the right with a list of the base branches
(with annotations) and an indented list of dependencies (branches) to
merge.

Such structure can nest::

  branch
    branch
      dependencies
    branch
    branch <- base .. base
    ...

Bases will be split off into a separate root when they also contain
dependencies that cannot be represented compactly. The branch is adorned
with [brackets] when this happens to indicate an indirect node::

  branch <- [base]

Branches are highlighted with the following:

:Red: Branch is missing or non-existent
:Bold: Branch needs to be updated
:Green: Branch contains updated content

Branches can be adorned with:

:``>branch``: Branch is the current branch
:``branch*``: Branch was the initial branch when ``git-assembler`` was
	      called and interrupted before finishing


Structure
---------

.. code::

   branch
     merge
     ...

``merge`` are branches which get merged into ``branch`` whenever they're
newer, and can be added using the `merge` command. The list of merged
branches follows the final merge order. ``branch`` is a regular branch,
unless followed by other symbols.

.. code::

   branch <- base

``branch`` is rebased on top of ``base`` when base is updated. It is
generated by the `rebase` command.

.. code::

   branch .. base

``branch`` can be bootstrapped or re-created on top of ``base``.
Generated by the `base` command.

.. code::

   branch <= base
     merge

``branch`` is deleted and re-created on top of ``base`` whenever either
``base`` or ``merge`` is newer. Generated by the `stage` command.

.. code::

   branch
     definition
   master <- [branch]

``[branch]`` refers to a branch defined elsewhere in the graph.


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

Empty lines and lines starting with "#" are ignored. Leading and
trailing whitespace is also ignored, allowing both commands and comments
to be indented. Each command starts on it's own line.

Commands that define a branch type (``base``, ``stage``, ``rebase``)
cannot be specified more than once per target. Ordering is only relevant
for the ``merge`` command.


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
   dependencies (base or merged branches) are updated.

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

   Note that fast-forward is used when possible (i.e. ``--ff``). This behavior
   can be modified with `assembler.mergeff`_.


Editor support
--------------

`git-assembler-mode <https://melpa.org/#/git-assembler-mode>`_ is an
Emacs major-mode to edit assembly files. Available through Melpa.


Configuration
=============

It is possible to configure ``git-assembler``'s behavior via
``git config`` or environment variables. Below is a reference of the supported
configuration keys. Environment variables override values possibly set with
``git config``.

assembler.mergeff
-----------------

:Key: ``assembler.mergeff``
:Env variable: ``GIT_ASSEMBLER_MERGEFF``
:Possible Values:
   ``true`` or ``false`` (or any boolean value accepted by
   ``git config``)
:Default: ``true``
:Description:
   If ``true`` (the default), instructs ``git-assembler`` to use the
   flag ``--ff`` when doing merges. If ``false``, the flag ``--no-ff``
   is used instead.


Recommendations
===============

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

  # enable in the current repository only
  git config rerere.enable true
  # or enable for all repositories
  git config --global rerere.enable true

Good familiarity with git-rerere_ is recommended.

Ensure the git ``reflog`` (``core.logAllRefUpdates``) has not been
disabled. It is essential for the correct operation of non-trivial
rebase operations.

.. _git-rerere: https://git-scm.com/docs/git-rerere


Authors and Copyright
=====================

| Copyright(c) 2019-2020 by wave++ "Yuri D'Elia" <wavexx@thregr.org>
| Distributed under the GNU GPLv3+ license, WITHOUT ANY WARRANTY.

``git-assembler``'s GIT repository is publicly accessible at:

https://gitlab.com/wavexx/git-assembler
