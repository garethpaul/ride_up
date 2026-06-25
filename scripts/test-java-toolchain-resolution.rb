#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'java-contract-runner'

def with_environment(values)
  previous = values.to_h { |name, _value| [name, ENV[name]] }
  values.each do |name, value|
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
  yield
ensure
  previous.each do |name, value|
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end

with_environment('JAVA_HOME' => nil, 'JAVAC' => nil, 'JAVA' => nil) do
  abort 'expected javac PATH fallback' unless JavaContractRunner.tool('JAVAC', 'javac') == 'javac'
  abort 'expected java PATH fallback' unless JavaContractRunner.tool('JAVA', 'java') == 'java'
end

with_environment('JAVA_HOME' => '/opt/jdk', 'JAVAC' => nil, 'JAVA' => nil) do
  expected_javac = File.join('/opt/jdk', 'bin/javac')
  expected_java = File.join('/opt/jdk', 'bin/java')
  abort 'expected JAVA_HOME javac' unless JavaContractRunner.tool('JAVAC', 'javac') == expected_javac
  abort 'expected JAVA_HOME java' unless JavaContractRunner.tool('JAVA', 'java') == expected_java
end

with_environment(
  'JAVA_HOME' => '/opt/jdk',
  'JAVAC' => '/custom/javac',
  'JAVA' => '/custom/java'
) do
  abort 'expected JAVAC override' unless JavaContractRunner.tool('JAVAC', 'javac') == '/custom/javac'
  abort 'expected JAVA override' unless JavaContractRunner.tool('JAVA', 'java') == '/custom/java'
end

puts 'Java toolchain resolution tests passed.'
