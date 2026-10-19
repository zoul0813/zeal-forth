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


def check_error(binary, s, word, label, depth, overflow=False, prefix="", gate=None):
    operands = ' '.join(str(4660 + i) for i in range(depth))
    setup = '1023 0 do 0 loop 4660' if overflow else operands
    extra = []
    if word == '+!':
        address = s['_dword_num']
        setup = f'4660 {address} ! ' + (str(address) if depth else '')
        extra = [f'r16 {address}']
    source = prefix + f': exercise {setup} {word} ;\nexercise\n'
    commands = [] if gate is None else [
        f'bp {s[gate]}', 'c', f'bc {s[gate]}',
    ]
    commands += [f'bp {s[label]}', 'c'] + snapshot(s) + extra + [
        f'bc {s[label]}', f'bp {s["prompt"]}', 'c',
    ] + snapshot(s) + extra + [f'bc {s["prompt"]}'] + recovery_commands(s)
    output = console(binary, source, commands)
    pauses = [(int(a, 16), int(c)) for a, c in PAUSED.findall(output)][2:]
    expected_pauses = [s[label], s['prompt'], s['print_ok']]
    if gate is not None:
        expected_pauses.insert(0, s[gate])
    assert [a for a, _ in pauses] == expected_pauses, output
    message = 'stkovf error' if overflow else 'stkunf error'
    assert output.count(message) == 1, output
    reads = memory_reads(output)
    # Each full snapshot has one pointer read and 128 lines of 16 bytes.
    size = 129 + len(extra)
    before, after = reads[:size], reads[size:2 * size]
    differences = [(a, b) for a, b in zip(before, after) if a != b]
    assert len(before) == len(after) == size and not differences, (
        word, depth, len(reads), differences[:3])
    expected_depth = 1024 if overflow else depth
    assert before[0] == (f'{s["data_sp"]:04x}',
                         f'{s["_data_stack_end"] - 2 * expected_depth:04x}'), output
    assert reads[2 * size:] == [
        (f'{s["data_sp"]:04x}', f'{s["_data_stack_end"] - 2:04x}'),
        (f'{s["_data_stack_end"] - 2:04x}', '0003'),
    ], output


def memory_reads(output):
    return re.findall(r'\[DBG\] (?:0x)?([0-9a-f]{4}): ([0-9a-f ]+)\n', output)


def check_definition_error(binary, s, word, value, name, message, here=None):
    source = f'{value} {word} {name}\n'
    entry = s['word_' + word]
    # Discover the allocation start after builtin dictionary initialization.
    probe = console(binary, source, [f'bp {entry}', 'c', f'r16 {s["HERE"]}'])
    start = int(memory_reads(probe)[0][1], 16) if here is None else here
    patch = [] if here is None else [
        f'wb {s["HERE"]} {here & 255} {here >> 8}',
    ]
    checks = snapshot(s) + [f'r16 {s["HERE"]}', f'r16 {s["LATEST"]}']
    # Check bytes that a partially emitted header would overwrite as well.
    length = min(64, max(0, 64511 - start))
    if length:
        checks += [f'rb {start} {length}']
    output = console(binary, source, [f'bp {entry}', 'c'] + patch + checks + [
        f'bc {entry}', f'bp {s["prompt"]}', 'c',
    ] + checks + [f'bc {s["prompt"]}'] + recovery_commands(s))
    pauses = [int(a, 16) for a, _ in PAUSED.findall(output)][2:]
    assert pauses == [entry, s['prompt'], s['print_ok']], output
    assert output.count(message + ' error') == 1, output
    reads = memory_reads(output)
    size = 131 + (length + 15) // 16
    assert reads[:size] == reads[size:2 * size], (word, value, name, message)
    assert len(reads) == 2 * size + 2, output
    assert reads[-2:] == [
        (f'{s["data_sp"]:04x}', f'{s["_data_stack_end"] - 2:04x}'),
        (f'{s["_data_stack_end"] - 2:04x}', '0003'),
    ], output


def check_definition_boundary(binary, s, word, count, name='x'):
    data_size = count * 2 if word == 'array' else 0
    start = 64511 - (len(name) + 12 + data_size)
    base = start + len(name) + 12
    source = f'{count} {word} {name} ' + ('0 ' if word == 'array' else '') + name + '\n'
    entry = s['word_' + word]
    commands = [f'bp {entry}', 'c',
                f'wb {s["HERE"]} {start & 255} {start >> 8}']
    if data_size:
        commands += [f'wb {base} ' + ' '.join(['165'] * data_size)]
    commands += [f'bc {entry}', f'bp {s["print_ok"]}', 'c',
                 f'r16 {s["HERE"]}', f'r16 {s["LATEST"]}',
                 f'r16 {s["data_sp"]}', f'r16 {s["_data_stack_end"] - 2}']
    if data_size:
        commands += [f'rb {base} {data_size}']
    output = console(binary, source, commands)
    pauses = [int(a, 16) for a, _ in PAUSED.findall(output)][2:]
    assert pauses == [entry, s['print_ok']], output
    expected = [
        (f'{s["HERE"]:04x}', f'{64511:04x}'),
        (f'{s["LATEST"]:04x}', f'{start:04x}'),
        (f'{s["data_sp"]:04x}', f'{s["_data_stack_end"] - 2:04x}'),
        (f'{s["_data_stack_end"] - 2:04x}', f'{base if word == "array" else count:04x}'),
    ]
    if data_size:
        expected += [(f'{base:04x}', 'a5 ' * data_size)]
    assert memory_reads(output) == expected, output
    assert ' error' not in output, output


def native_benchmarks(binary, s):
    comparisons = [
        ('array', ': old-array create cells allot does> swap cells + ;\n',
         '1000 array xs', '1000 old-array xs',
         'variable base 0 xs base !', '0', 'i xs +', 'base @ 1000 * -', 999000 & 65535),
        ('constant', ': old-constant create , does> @ ;\n',
         '42 constant answer', '42 old-constant answer',
         '', '0', 'answer +', '', 42000),
        ('+!', ': old-plus-store dup @ rot + swap ! ;\n',
         '', '', 'variable total 0 total !', '',
         '1 total {operation}', 'total @', 1000),
        ('1+', ': old-one-plus 1 + ;\n',
         '', '', '', '65500', '{operation}', '', (65500 + 1000) & 65535),
        ('1-', ': old-one-minus 1 - ;\n',
         '', '', '', '10', '{operation}', '', (10 - 1000) & 65535),
    ]
    references = {'+!': 'old-plus-store', '1+': 'old-one-plus', '1-': 'old-one-minus'}
    for word, reference, native_def, old_def, setup, initial, body, finish, expected in comparisons:
        results = []
        for old in (True, False):
            operation = references.get(word, word) if old else word
            loop_body = body.format(operation=operation)
            definition = old_def if old else native_def
            source = (reference + definition + '\n' + setup + '\n' +
                      f': bench {initial} 1000 0 do {loop_body} loop ;\n' +
                      f'bench {finish} bye\n')
            output = console(binary, source, [
                f'bp {s["do_init"]}', 'c', f'bc {s["do_init"]}',
                f'bp {s["do_unwind"]}', 'c', f'bc {s["do_unwind"]}',
                f'bp {s["word_bye"]}', 'c',
                f'r16 {s["data_sp"]}', f'r16 {s["_data_stack_end"] - 2}',
            ])
            pauses = [(int(a, 16), int(c)) for a, c in PAUSED.findall(output)][2:]
            assert [a for a, _ in pauses] == [s['do_init'], s['do_unwind'], s['word_bye']], output
            assert memory_reads(output) == [
                (f'{s["data_sp"]:04x}', f'{s["_data_stack_end"] - 2:04x}'),
                (f'{s["_data_stack_end"] - 2:04x}', f'{expected:04x}'),
            ], output
            results.append(pauses[1][1] - pauses[0][1])
        old, native = results
        assert native < old, (word, results)
        print(f'{word}: {old:,} -> {native:,} T-states; '
              f'saved {old - native:,} ({(old - native) / old:.1%}), 1000 iterations')


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
        ('c!', 'word_store_char', 2), ('+!', 'word_plus_store', 2),
        ('1+', 'word_one_plus', 1), ('1-', 'word_one_minus', 1),
        ('array', 'word_array', 1), ('constant', 'word_constant', 1),
    ]
    count = 0
    for word, label, required in cases:
        for depth in range(required):
            check_error(binary, s, word, label, depth)
            count += 1
    for word, label in [('dup', 'word_dup'), ('over', 'word_over')]:
        check_error(binary, s, word, label, 1024, overflow=True)
        count += 1
    check_error(binary, s, 'xs', 'array_runtime', 0, prefix='1 array xs\n')
    check_error(binary, s, '2/ answer', 'pushdata', 1024, overflow=True,
                prefix='42 constant answer\n', gate='word_two_slash')
    count += 2
    for word in ('array', 'constant'):
        for name, message in [('', 'noname'), ('x' * 32, 'lenovf')]:
            check_definition_error(binary, s, word, 1, name, message)
            count += 1
        check_definition_error(binary, s, word, 1, 'x', 'dictovf', here=64511 - 12)
        check_definition_error(binary, s, word, 1, 'x', 'dictovf', here=65528)
        count += 2
    for value, message in [(-1, 'numovf'), (32768, 'numovf'), (65535, 'numovf'),
                           (32767, 'dictovf')]:
        check_definition_error(binary, s, 'array', value, 'x', message)
        count += 1
    check_definition_boundary(binary, s, 'array', 2)
    check_definition_boundary(binary, s, 'array', 0)
    check_definition_boundary(binary, s, 'constant', 1234, name='x' * 31)
    print('Definition boundaries passed: exact fit, zero length, 31-byte name, uninitialized storage')
    native_benchmarks(binary, s)
    print(f'{count} isolated errors passed: exact messages, unchanged stack, recovery arithmetic')
    optimized = benchmark(binary, s)
    print(f'Compiled 1000-iteration loop: {optimized:,} T-states (console output excluded)')
    if args.baseline_bin:
        baseline = benchmark(args.baseline_bin, symbols(args.baseline_map))
        saved = baseline - optimized
        print(f'Baseline: {baseline:,}; saved {saved:,} T-states ({saved / baseline:.1%})')


if __name__ == '__main__':
    main()
