cd h:/

echo === FORTH-TEST-BEGIN:base ===
forth h:/.headless/base.fs
echo === FORTH-TEST-END:base ===

echo === FORTH-TEST-BEGIN:math ===
forth h:/.headless/math.fs
echo === FORTH-TEST-END:math ===

echo === FORTH-TEST-BEGIN:compare ===
forth h:/.headless/compare.fs
echo === FORTH-TEST-END:compare ===

echo === FORTH-TEST-BEGIN:stack ===
forth h:/.headless/stack.fs
echo === FORTH-TEST-END:stack ===

echo === FORTH-TEST-BEGIN:memory ===
forth h:/.headless/memory.fs
echo === FORTH-TEST-END:memory ===

echo === FORTH-TEST-BEGIN:compile ===
forth h:/.headless/compile.fs
echo === FORTH-TEST-END:compile ===

echo === FORTH-TEST-BEGIN:flow ===
forth h:/.headless/flow.fs
echo === FORTH-TEST-END:flow ===

echo === FORTH-TESTS-COMPLETE ===
reset
