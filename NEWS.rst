git-assembler 1.2: 2020-09-23
-----------------------------

Improved worktree support thanks to Etienne Laurin:

* Allow to create staging branches even when the base branch is already
  checked out in a different worktree.
* Fix internal state paths when using worktrees.

General bug fixes:

* Fix dirty graph state/coloring when using ``base`` and merging with
  the base branch itself.
* Read correctly assembly files with a missing EOL (thanks to
  Etienne Laurin).
* Handle checkout errors without a spurious traceback when referring to
  undefined branches.

Minor improvements:

* Remove useless commit error messages when performing a rerere
  autocommit.


git-assembler 1.1: 2020-08-03
-----------------------------

* Fixes ``rebase`` behavior, thanks to Richard Nguyen.
* Tests portability fixes, thanks to Carlo Arenas.
* New ``--color`` flag to control terminal coloring.
* Fixes failure to restore starting branch in some cases.
