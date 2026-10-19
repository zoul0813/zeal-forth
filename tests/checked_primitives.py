#!/usr/bin/env python3
"""Debugger checks for atomic stack failures and compiled-loop cycle counts.

Runs with ./test.py or standalone after a build. Baseline options compare an earlier
build without rebuilding or replacing the working tree's binary.
"""

import argparse
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
PAUSED = re.compile(r'Paused @ 0x([0-9a-f]+) \(cyc=(\d+)\)')


def symbols(path):
    return {name: int(value, 16) for name, value in re.findall(
        r'^(\S+)\s+= \$([0-9A-Fa-f]+)', path.read_text(), re.M)}


def console(binary, source, commands):
    with tempfile.TemporaryDirectory(prefix='forth-checked-') as directory:
        host = Path(directory)
        shutil.copy(binary, host / 'forth')
        (host / 'case.fs').write_text(source)
        (host / 'test.zs').write_text(
            'cd h:/\nh:/forth h:/case.fs\nreset\n')
        # An explicit TF image avoids depending on a user's configured card.
        shutil.copy(ROOT / '.zeal8bit/eeprom.img', host / 'tf.img')
        # Both ZShell and Forth enter at 0x4000. Wait for Forth before
        # arming word breakpoints: ZShell shares the same virtual addresses.
        script = ['bp 16384', 'c', 'c', 'bc 16384'] + commands + ['quit']
        result = subprocess.run([
            'zeal-native', '--console', '--debug',
            '-r', str(ROOT / '.zeal8bit/headless.img'),
            '-e', str(ROOT / '.zeal8bit/eeprom.img'),
            '-t', str(host / 'tf.img'), '-H', str(host),
        ], input='\n'.join(script) + '\n', text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
        if result.returncode:
            raise AssertionError(result.stdout)
        return result.stdout


def snapshot(s):
    return [f'r16 {s["data_sp"]}'] + [
        f'rb {s["data_stack"] + offset} 256' for offset in range(0, 2048, 256)]


def recovery_commands(s):
    # Exercise the real cooked keyboard path after the error reaches PROMPT.
    # Stop at print_ok so the snapshot precedes any file-loader continuation.
    commands = []
    for key in ['W', 'I', 'P', 'E', 'SPACE', '1', 'SPACE', '2', 'SPACE']:
        commands += [f'tap {key}', 'run 1000000']
    return commands + [
        'press SHIFT', 'tap EQUAL', 'run 1000000', 'release SHIFT',
        'run 1000000', f'bp {s["print_ok"]}', 'tap ENTER', 'c',
        f'r16 {s["data_sp"]}', f'r16 {s["_data_stack_end"] - 2}',
    ]


def check_error(binary, s, word, label, depth, overflow=False):
    operands = ' '.join(str(4660 + i) for i in range(depth))
    setup = '1023 0 do 0 loop 4660' if overflow else operands
    source = f': exercise {setup} {word} ;\nexercise\n'
    commands = [f'bp {s[label]}', 'c'] + snapshot(s) + [
        f'bc {s[label]}', f'bp {s["prompt"]}', 'c',
    ] + snapshot(s) + [f'bc {s["prompt"]}'] + recovery_commands(s)
    output = console(binary, source, commands)
    pauses = [(int(a, 16), int(c)) for a, c in PAUSED.findall(output)][2:]
    assert [a for a, _ in pauses] == [s[label], s['prompt'], s['print_ok']], output
    message = 'stkovf error' if overflow else 'stkunf error'
    assert output.count(message) == 1, output
    reads = re.findall(r'\[DBG\] (?:0x)?([0-9a-f]{4}): ([0-9a-f ]+)\n', output)
    # Each full snapshot has one pointer read and 128 lines of 16 bytes.
    before, after = reads[:129], reads[129:258]
    differences = [(a, b) for a, b in zip(before, after) if a != b]
    assert len(before) == len(after) == 129 and not differences, (
        word, depth, len(reads), differences[:3])
    expected_depth = 1024 if overflow else depth
    assert before[0] == (f'{s["data_sp"]:04x}',
                         f'{s["_data_stack_end"] - 2 * expected_depth:04x}'), output
    assert reads[258:] == [
        (f'{s["data_sp"]:04x}', f'{s["_data_stack_end"] - 2:04x}'),
        (f'{s["_data_stack_end"] - 2:04x}', '0003'),
    ], output


def benchmark(binary, s):
    source = ': bench 1000 0 do i 1000 swap cells + drop loop ;\nbench\nbye\n'
    output = console(binary, source, [
        f'bp {s["do_init"]}', 'c', f'bc {s["do_init"]}',
        f'bp {s["do_unwind"]}', 'c',
    ])
    pauses = [(int(a, 16), int(c)) for a, c in PAUSED.findall(output)][2:]
    assert [a for a, _ in pauses] == [s['do_init'], s['do_unwind']], output
    return pauses[1][1] - pauses[0][1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline-bin', type=Path)
    parser.add_argument('--baseline-map', type=Path)
    args = parser.parse_args()
    if bool(args.baseline_bin) != bool(args.baseline_map):
        parser.error('provide both baseline paths')
    binary = ROOT / 'bin/forth'
    s = symbols(ROOT / 'debug/forth.map')
    cases = [
        ('dup', 'word_dup', 1), ('drop', 'word_drop', 1),
        ('swap', 'word_swap', 2), ('over', 'word_over', 2),
        ('rot', 'word_rot', 3), ('+', 'word_plus', 2),
        ('-', 'word_minus', 2), ('2*', 'word_two_star', 1),
        ('2/', 'word_two_slash', 1), ('@', 'word_fetch', 1),
        ('c@', 'word_fetch_char', 1), ('!', 'word_store', 2),
        ('c!', 'word_store_char', 2),
    ]
    count = 0
    for word, label, required in cases:
        for depth in range(required):
            check_error(binary, s, word, label, depth)
            count += 1
    for word, label in [('dup', 'word_dup'), ('over', 'word_over')]:
        check_error(binary, s, word, label, 1024, overflow=True)
        count += 1
    print(f'{count} isolated errors passed: exact messages, unchanged stack, recovery arithmetic')
    optimized = benchmark(binary, s)
    print(f'Compiled 1000-iteration loop: {optimized:,} T-states (console output excluded)')
    if args.baseline_bin:
        baseline = benchmark(args.baseline_bin, symbols(args.baseline_map))
        saved = baseline - optimized
        print(f'Baseline: {baseline:,}; saved {saved:,} T-states ({saved / baseline:.1%})')


if __name__ == '__main__':
    main()
