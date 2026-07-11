cd h:/

echo === FORTH-TEST-BEGIN:base ===
forth h:/forth.fs h:/tests/unit/base.fs
echo === FORTH-TEST-END:base ===

echo === FORTH-TEST-BEGIN:math ===
forth h:/forth.fs h:/tests/unit/math.fs
echo === FORTH-TEST-END:math ===

echo === FORTH-TEST-BEGIN:compare ===
forth h:/forth.fs h:/tests/unit/compare.fs
echo === FORTH-TEST-END:compare ===

echo === FORTH-TEST-BEGIN:stack ===
forth h:/forth.fs h:/tests/unit/stack.fs
echo === FORTH-TEST-END:stack ===

echo === FORTH-TEST-BEGIN:memory ===
forth h:/forth.fs h:/tests/unit/memory.fs
echo === FORTH-TEST-END:memory ===

echo === FORTH-TEST-BEGIN:compile ===
forth h:/forth.fs h:/tests/unit/compile.fs
echo === FORTH-TEST-END:compile ===

echo === FORTH-TEST-BEGIN:flow ===
forth h:/forth.fs h:/tests/unit/flow.fs
echo === FORTH-TEST-END:flow ===

echo === FORTH-TESTS-COMPLETE ===
reset
