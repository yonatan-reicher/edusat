from pathlib import Path
from typing import Generator
import enum
import os
import subprocess
import sys
import time


def get_file_paths_in_dir(dir_path) -> Generator[Path, None, None]:
    for root, _, files in os.walk(dir_path):
        for file in files:
            yield Path(root) / file


def cnf_file_path_generator():
    dir_path = "./benchmarks"
    for file_path in get_file_paths_in_dir(dir_path):
        if file_path.suffix == ".cnf":
            yield file_path


class Mode(enum.IntEnum):
    NORMAL = 0
    INCREMENTAL = 1


class Sat(enum.StrEnum):
    SAT = 'SAT'
    UNSAT = 'UNSAT'


class Time(float): pass


class Timeout: pass


RunResult = tuple[Sat, Time] | Timeout


def run_on(file_path: Path, debug: bool, mode: Mode) -> RunResult:
    folder_name = "Debug" if debug else "Release"
    folder = Path(f"./{folder_name}/")
    exe = folder / "edusat.exe"
    start_time = time.time()
    try:
        res = subprocess.run(
            [
                exe,
                "-mode", str(mode),
                file_path,
            ],
            stdout=subprocess.PIPE,
            timeout=1.5,
        )
        elapsed_time = time.time() - start_time

        last_line = res.stdout.decode().split()[-1]
        sat = Sat.SAT if last_line == "SAT" else Sat.UNSAT if last_line == "UNSAT" else None
        if sat is None:
            raise Exception(f"Bad output. Last line: {last_line}")
        
        return (sat, Time(elapsed_time))

    except subprocess.TimeoutExpired:
        return Timeout()


def mode_string(mode: Mode) -> str: return f"Mode {mode.name}:"
max_mode_string_length = max(len(mode_string(mode)) for mode in Mode)


def run_test_by_path(cnf_file_path: Path, debug: bool) -> dict[Mode, RunResult]:
    return {
        mode: run_on(cnf_file_path, debug=debug, mode=mode)
        for mode in Mode
    }


def print_mode_run_results_dict(d: dict[Mode, RunResult]):
    for mode in Mode:
        match d[mode]:
            case Timeout():
                print(f"{mode_string(mode): <{max_mode_string_length}} Timeout.")
            case (sat, time):
                print(f"{mode_string(mode): <{max_mode_string_length}} Took {time:.3} second. Result {sat}.")


def run_test_by_name(test_name: str, debug: bool):
    matching_files = [file_path for file_path in cnf_file_path_generator() if test_name in str(file_path)]
    match matching_files:
        case []:
            print(f"No test found for {test_name}")
        case [_, _, *_]:
            print(f"Multiple tests found for {test_name}:")
            for file_path in matching_files:
                print(file_path)
        case [file_path]:
            run_test_by_path(file_path, debug=debug)


def run_tests_by_pattern(pattern: str, debug: bool):
    matching_files = [file_path for file_path in cnf_file_path_generator() if pattern in str(file_path)]
    
    if not matching_files:
        print(f"No test found for {pattern}")
        return

    for cnf_file_path in matching_files:
        print(f"Run {cnf_file_path}:")
        result = run_test_by_path(cnf_file_path, debug=debug)
        print_mode_run_results_dict(result)


def run_all_tests(debug: bool):
    print("Running tests, sorted by file size")
    all_cnf_files = list(cnf_file_path_generator())
    all_cnf_files.sort(key = lambda path: path.stat().st_size)

    for cnf_file_path in all_cnf_files:
        print(f"Run {cnf_file_path}:")
        result = run_test_by_path(cnf_file_path, debug=debug)
        print_mode_run_results_dict(result)


def show_help():
    print('''
Usage:
    python test.py [test_name]
    python test.py --pattern <pattern>

[test_name]: Run test with name containing test_name. If not given, all tests.
<pattern>: Run all tests containing the pattern in their name.
    '''.strip())


def main():
    args = sys.argv[1:]
    debug = False
    match args:
        case ['--help'] | ['-h']: show_help()
        case []: run_all_tests(debug=debug)
        case [test_name]: run_test_by_name(test_name, debug=debug)
        case ['--pattern', test_name]: run_tests_by_pattern(test_name, debug=debug)
        case _: show_help()

if __name__ == '__main__':
    main()
