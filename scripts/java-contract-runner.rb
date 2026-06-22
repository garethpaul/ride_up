# frozen_string_literal: true

require 'fileutils'
require 'open3'

module JavaContractRunner
  class HarnessError < StandardError
  end

  module_function

  def compile!(javac, sources, output, context:)
    FileUtils.mkdir_p(output)
    command_output, status = capture(
      javac, '-source', '7', '-target', '7', '-d', output.to_s,
      *sources.map(&:to_s), unavailable: 'Java compiler', context: context
    )
    return command_output if status.success?

    raise HarnessError, "#{context} failed to compile:\n#{command_output}"
  end

  def run_test!(java, output, test_class, context:)
    command_output, status = capture(
      java, '-cp', output.to_s, test_class,
      unavailable: 'Java runtime', context: context
    )
    return command_output if status.success?

    raise HarnessError, "#{context} failed while running #{test_class}:\n#{command_output}"
  end

  def reject_mutant!(javac, java, sources, output, test_classes, expected_assertion, context:)
    compile!(javac, sources, output, context: context)
    expected_failure = "java.lang.AssertionError: #{expected_assertion}"

    test_classes.each do |test_class|
      command_output, status = capture(
        java, '-cp', output.to_s, test_class,
        unavailable: 'Java runtime', context: context
      )
      next if status.success?
      return if command_output.include?(expected_failure)

      raise HarnessError,
            "#{context} failed for an unintended reason in #{test_class}:\n#{command_output}"
    end

    raise HarnessError, "#{context} was accepted"
  end

  def capture(*command, unavailable:, context:)
    Open3.capture2e(*command)
  rescue Errno::ENOENT
    raise HarnessError, "#{unavailable} unavailable for #{context}: #{command.first}"
  end
  private_class_method :capture
end
