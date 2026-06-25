#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'tmpdir'
require_relative 'java-contract-runner'

javac = JavaContractRunner.tool('JAVAC', 'javac')
java = JavaContractRunner.tool('JAVA', 'java')

def expect_harness_failure(message)
  yield
  abort "expected harness failure: #{message}"
rescue JavaContractRunner::HarnessError => error
  abort "unexpected harness failure: #{error.message}" unless error.message.include?(message)
end

Dir.mktmpdir('ride-up-java-contract-runner') do |directory|
  root = Pathname.new(directory)
  source = root.join('Example.java')
  test = root.join('ExampleTest.java')
  source.write("final class Example { static int value() { return 1; } }\n")
  test.write(<<~JAVA)
    public final class ExampleTest {
        public static void main(String[] args) {
            if (Example.value() != 1) {
                throw new AssertionError("expected value");
            }
        }
    }
  JAVA

  expect_harness_failure('Java compiler unavailable') do
    JavaContractRunner.compile!(
      File.join(directory, 'missing-javac'), [source, test], root.join('missing-classes'),
      context: 'missing compiler self-test'
    )
  end

  broken_source = root.join('BrokenExample.java')
  broken_source.write("final class BrokenExample { syntax error }\n")
  expect_harness_failure('failed to compile') do
    JavaContractRunner.reject_mutant!(
      javac, java, [broken_source], root.join('broken-classes'), ['ExampleTest'],
      'expected value', context: 'syntax-error mutant self-test'
    )
  end

  classes = root.join('classes')
  JavaContractRunner.compile!(
    javac, [source, test], classes, context: 'baseline self-test'
  )
  JavaContractRunner.run_test!(
    java, classes, 'ExampleTest', context: 'baseline self-test'
  )

  expect_harness_failure('Java runtime unavailable') do
    JavaContractRunner.run_test!(
      File.join(directory, 'missing-java'), classes, 'ExampleTest',
      context: 'missing runtime self-test'
    )
  end
end

puts 'Java contract runner self-tests passed.'
