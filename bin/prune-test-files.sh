#!/usr/bin/env sh
set -ux

# Synopsis:
# Helpful for local testing as the UCM writes files as a result of the transcript process.

exit_code=0

# Iterate over all test directories
for test_dir in tests/*; do
    test_dir_path=$(realpath "${test_dir}")
    results_file_path="${test_dir_path}/results.json"
    test_loader_name="${test_dir_path}/.meta/testLoader.output.md"

    echo "removing ${results_file_path}"
    rm "${results_file_path}"
    echo "removing ${test_loader_name}"
    rm "${test_loader_name}"
done

exit ${exit_code}
