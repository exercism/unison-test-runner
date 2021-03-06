# Exercism Unison Test Runner

The Docker image to automatically run tests on Unison solutions submitted to [Exercism].

## Run the test runner

To run the tests of an arbitrary exercise, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run.sh <exercise-slug> <solution-dir> <output-dir>`

Once the test runner has finished, its results will be written to `<output-dir>/results.json`.

## Run the test runner on an exercise using Docker

_This script is provided for testing purposes, as it mimics how test runners run in Exercism's production environment._

To run the tests of an arbitrary exercise using the Docker image, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-in-docker.sh <exercise-slug> <solution-dir> <output-dir>`

Once the test runner has finished, its results will be written to `<output-dir>/results.json`.

If you are using Docker on an M1 mac, you'll need to build a docker image using `DockerfileMac`: `docker build -t exercism/test-runner -f DockerfileMac .` The M1 Mac build of the UCM is `ucm-arm64` and it is too large for standard git storage, contact one of the Unison maintainers for the file.

## Run the tests

To run the tests to verify the behavior of the test runner, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-tests.sh`

These are [golden tests][golden] that compare the `results.json` generated by running the current state of the code against the "known good" `tests/<test-name>/results.json`. All files created during the test run itself are discarded.

When you've made modifications to the code that will result in a new "golden" state, you'll need to generate and commit a new `tests/<test-name>/results.json` file.

## Run the tests using Docker

_This script is provided for testing purposes, as it mimics how test runners run in Exercism's production environment._

To run the tests to verify the behavior of the test runner using the Docker image, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-tests-in-docker.sh`

These are [golden tests][golden] that compare the `results.json` generated by running the current state of the code against the "known good" `tests/<test-name>/results.json`. All files created during the test run itself are discarded.

When you've made modifications to the code that will result in a new "golden" state, you'll need to generate and commit a new `tests/<test-name>/results.json` file.

[test-runners]: https://github.com/exercism/docs/tree/main/building/tooling/test-runners
[golden]: https://ro-che.info/articles/2017-12-04-golden-tests
[exercism]: https://exercism.io

# How the Unison test runner works

The Unison test runner relies on a few conventions and contracts between the Unison Exercism repo proper and the files found here.

1. Every solution's `name.test.u` file should expose a variable `tests` of type `[base.Test]`
2. Every solution directory contains two files under `.meta`, one called `testAnnotation.json`, and another called `testLoader.md`.
3. `testAnnotation.json` is used to capture the values that would otherwise be defined via metaprogramming or codebase introspection, in this case, individual test names and the body of the test itself.
3. The `src` directory in the test runner repo contains the files responsible for writing the Json output file. They rely on environment variables set by the `export` statements in the `run.sh` script.
4. Currently this test runner is targeting v2 of the api spec.

## General workflow

* The dockerfile initializes a codebase which contains the standard lib, parser, and json libraries needed to run the tests.
* User submits test
* UCM transcript runner tries to load and add the user's files to a temp codebase with `testLoader.md`
* If the code typechecks...
   * The `testRunner.md` transcript runs the `testMain.u` file
   * The json file containing test results is created
* If the users code does not typecheck...
   * The json result file is not created. The UCM runs `errorRunner.md` to read the transcript output file produced by `testLoader.md`. It's called `testLoader.output.md` and it is always located in the same directory as its associated transcript.
   * The `errorMain.u` code looks for the transcript failure message, and writes the json output file with associated status and message.