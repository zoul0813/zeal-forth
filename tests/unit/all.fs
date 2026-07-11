\ Unit test checklist (manual runner).
\ Usage:
\   loadfile "tests/unit/all.fs"
\
\ NOTE:
\   Nested loadfile calls are not currently safe because the loader uses a
\   single global file descriptor/state. Run each test file manually from the
\   prompt instead.
\
\ Suggested order:
\   loadfile "tests/unit/base.fs"
\   loadfile "tests/unit/math.fs"
\   loadfile "tests/unit/compare.fs"
\   loadfile "tests/unit/stack.fs"
\   loadfile "tests/unit/memory.fs"
\   loadfile "tests/unit/compile.fs"
\   loadfile "tests/unit/flow.fs"
