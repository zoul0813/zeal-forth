# Headless testing

Headless tests build Zeal Forth and run all files in `tests/unit` under Zeal Native. Each invocation loads `forth.fs` followed by one unit file through the multi-file CLI, and each unit file ends with `bye` to exit cleanly. Games are not part of this suite.

## Prerequisites

- ZDE and its Zeal OS source configuration
- A `zeal-native` build supporting `--headless --no-reset`
- `.zeal8bit/headless.img` and `.zeal8bit/eeprom.img`

The emulator images are local resources and are ignored by Git. Known-good copies can be copied from the sibling `zeal-cc/.zeal8bit` directory:

```shell
mkdir -p .zeal8bit
cp ../zeal-cc/.zeal8bit/headless.img .zeal8bit/
cp ../zeal-cc/.zeal8bit/eeprom.img .zeal8bit/
```

The EEPROM image must boot ZShell with a `B:/autoexec.zs` that sets `H:/bin` in `PATH` and runs `exec h:/test.zs`.

## Running tests

Run the complete suite:

```shell
./test.py
```

Print all emulator output while testing:

```shell
./test.py --headless-log
```

Save emulator output for debugging:

```shell
./test.py --headless-log-file headless.log
```

The runner allows 120 seconds for the emulator. Build failures, missing tools or images, timeouts, incomplete marker output, assertion failures, and unexpected `base.fs` console output produce a nonzero exit status.
