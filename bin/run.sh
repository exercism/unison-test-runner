#!/bin/sh
set -ux

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

# Create environment variables for the test runner
slug="$1"
export solution_dir=$(realpath "${2%%/}")
export output_dir=$(realpath "${3%%/}")
export results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it
runTests () {
  codebase=$(mktemp -d)
  cp -r /opt/test-runner/src/ /tmp/
  cp -a /opt/test-runner/tmp/testRunner/.unison "$codebase"/
  ucm transcript.fork "$solution_dir"/.meta/testLoader.md /tmp/src/testRunner.md --codebase "$codebase"
}
test_output=$(runTests 2>&1)

# Check to see if the json output file exists. If it does not,
# the user's code could not compile and the test run could not take place.
# Compose error message file with the error runner based on /tmp/src/testRunner.output.md.
runError () {
  codebase=$(mktemp -d)
  cp -a /opt/test-runner/tmp/testRunner/.unison "$codebase"/
  ucm transcript.fork /tmp/src/errorRunner.md --codebase "$codebase"
}
if [ ! -e "${results_file}" ]; then
  error_output=$(runError 2>&1)

  # Backup error file: If the UCM itself fails to start, capture the output.
  if [ $? -ne 0 ]; then

    # OPTIONAL: Sanitize the output
    # In some cases, the test output might be overly verbose, in which case stripping
    # the unneeded information can be very helpful to the student
    # sanitized_test_output=$(printf "${test_output}" | sed -n '/Test results:/,$p')

    # OPTIONAL: Manually add colors to the output to help scanning the output for errors
    # If the test output does not contain colors to help identify failing (or passing)
    # tests, it can be helpful to manually add colors to the output
    # colorized_test_output=$(echo "${test_output}" \
    #      | GREP_COLOR='01;31' grep --color=always -E -e '^(ERROR:.*|.*failed)$|$' \
    #      | GREP_COLOR='01;32' grep --color=always -E -e '^.*passed$|$')

    jq -n --arg output "${error_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
  fi
fi

echo "${slug}: done"
