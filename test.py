#!/usr/bin/env python3
"""Build and run Zeal Forth unit tests in zeal-native headless mode."""

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path


TIMEOUT_SECONDS = 120
IMAGE = Path(".zeal8bit/headless.img")
EEPROM = Path(".zeal8bit/eeprom.img")
SUITES = ("base", "math", "compare", "stack", "memory", "compile", "flow")
HEADLESS_DIR = Path(".headless")
SUMMARIES = {
    name: f"ALL {name.upper()} TESTS PASSED"
    for name in SUITES
    if name != "base"
}
BEGIN_RE = re.compile(r"^=== FORTH-TEST-BEGIN:([a-z]+) ===$")
END_RE = re.compile(r"^=== FORTH-TEST-END:([a-z]+) ===$")
COMPLETE_MARKER = "=== FORTH-TESTS-COMPLETE ==="

BASE_EXPECTED = [
    "Loading forth.fs Done.",
    "[ decimal 255 ] expected 255: 255",
    "[ decimal -42 ] expected -42: -42",
    "[ decimal 0 ] expected 0: 0",
    "[ hex FF ] expected FF: FF",
    "[ hex FFFF ] expected FFFF: FFFF",
    "[ hex -2A ] expected FFD6: FFD6",
    "[ hex 0 ] expected 0: 0",
    "[ hex 7FFF ] expected 7FFF: 7FFF",
    "[ hex 8000 ] expected 8000: 8000",
    "[ hex .s ] expected <3> 1 FF FFFF: <3> 1 FF FFFF",
    "[ hex .rs ] expected <2> 1 FF: <2> 1 FF",
    "[ decimal restored ] expected -42: -42",
]

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"


def header(title: str) -> None:
    print(f"\n{BLUE}{'=' * 40}{NC}")
    print(f"{BLUE}{title}{NC}")
    print(f"{BLUE}{'=' * 40}{NC}\n")


def fail(message: str) -> int:
    print(f"{RED}✗{NC} {message}")
    return 1


def normalize_line(line: str) -> str:
    return " ".join(line.replace("\r", "").strip().split())


def parse_sections(log: str) -> tuple[dict[str, list[str]], list[str]]:
    sections: dict[str, list[str]] = {}
    errors: list[str] = []
    current: str | None = None

    for raw in log.splitlines():
        line = normalize_line(raw)
        begin = BEGIN_RE.match(line)
        if begin:
            name = begin.group(1)
            if current is not None:
                errors.append(f"suite {current} has no end marker")
            if name in sections:
                errors.append(f"suite {name} has duplicate begin marker")
            sections[name] = []
            current = name
            continue

        end = END_RE.match(line)
        if end:
            name = end.group(1)
            if current != name:
                errors.append(f"suite {name} has mismatched end marker")
            current = None
            continue

        if current is not None and line:
            sections[current].append(line)

    if current is not None:
        errors.append(f"suite {current} has no end marker")
    for name in SUITES:
        if name not in sections:
            errors.append(f"suite {name} has no output markers")
    if COMPLETE_MARKER not in {normalize_line(line) for line in log.splitlines()}:
        errors.append("test completion marker missing")
    return sections, errors


def validate_suite(name: str, lines: list[str]) -> tuple[bool, str]:
    if name == "base":
        if lines == BASE_EXPECTED:
            return True, ""
        return False, "console output differs from expected output"

    summary = SUMMARIES[name]
    if any(re.search(r"(?:^|\s)FAIL(?:\s|$)", line) for line in lines):
        return False, "assertion output contains FAIL"
    if any(f"{name.upper()} TEST FAILURES:" in line for line in lines):
        return False, "failure summary reported"
    if summary not in lines:
        return False, f"missing summary: {summary}"
    return True, ""


def run_emulator(show_log: bool, log_file: Path | None) -> tuple[int, str]:
    command = [
        "zeal-native",
        "--headless",
        "--no-reset",
        "-r",
        str(IMAGE),
        "-e",
        str(EEPROM),
    ]
    try:
        result = subprocess.run(
            command,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired as exc:
        output = exc.stdout or ""
        if isinstance(output, bytes):
            output = output.decode("utf-8", errors="replace")
        if log_file:
            log_file.write_text(output, encoding="utf-8")
        if show_log and output:
            print(output, end="" if output.endswith("\n") else "\n")
        return fail(f"zeal-native timed out after {TIMEOUT_SECONDS}s"), output
    except OSError as exc:
        return fail(f"could not run zeal-native: {exc}"), ""

    output = result.stdout or ""
    if log_file:
        log_file.write_text(output, encoding="utf-8")
    if show_log and output:
        print(output, end="" if output.endswith("\n") else "\n")
    if result.returncode != 0:
        fail(f"zeal-native exited with status {result.returncode}")
    return result.returncode, output


def prepare_test_files() -> None:
    """Create single-loader inputs containing the core library, suite, and bye."""
    core = Path("forth.fs").read_text(encoding="utf-8")
    HEADLESS_DIR.mkdir(exist_ok=True)
    for name in SUITES:
        suite = Path(f"tests/unit/{name}.fs").read_text(encoding="utf-8")
        combined = f"{core.rstrip()}\n\n{suite.rstrip()}\n\nbye\n"
        (HEADLESS_DIR / f"{name}.fs").write_text(combined, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Run Zeal Forth headless tests")
    parser.add_argument("--headless-log", action="store_true", help="print emulator output")
    parser.add_argument(
        "--headless-log-file", type=Path, help="write emulator output to this file"
    )
    args = parser.parse_args()

    header("Building Zeal Forth")
    try:
        build = subprocess.run(["zde", "cmake"], check=False)
    except OSError as exc:
        return fail(f"could not run zde cmake: {exc}")
    if build.returncode != 0:
        return fail(f"zde cmake exited with status {build.returncode}")
    if not Path("bin/forth").is_file():
        return fail("build artifact missing: bin/forth")
    print(f"{GREEN}✓{NC} build artifact: bin/forth")

    try:
        prepare_test_files()
    except OSError as exc:
        return fail(f"could not prepare headless test files: {exc}")

    if shutil.which("zeal-native") is None:
        return fail("zeal-native not found in PATH")
    for resource in (IMAGE, EEPROM):
        if not resource.is_file():
            return fail(f"emulator resource missing: {resource}")

    header("Zeal-Native Headless Tests")
    emulator_status, log = run_emulator(args.headless_log, args.headless_log_file)
    sections, parse_errors = parse_sections(log)
    failures = list(parse_errors)
    passed = 0

    for name in SUITES:
        if name not in sections:
            print(f"{RED}✗{NC} {name}: missing")
            continue
        ok, reason = validate_suite(name, sections[name])
        if ok:
            print(f"{GREEN}✓{NC} {name}")
            passed += 1
        else:
            failures.append(f"{name}: {reason}")
            print(f"{RED}✗{NC} {name}: {reason}")

    for error in parse_errors:
        print(f"{RED}✗{NC} {error}")

    header("Test Summary")
    print(f"Suites passed: {passed}/{len(SUITES)}")
    if emulator_status != 0:
        failures.append("emulator failed")
    if failures:
        print(f"{RED}Headless suite failed{NC}")
        return 1
    print(f"{GREEN}All headless suites passed{NC}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
