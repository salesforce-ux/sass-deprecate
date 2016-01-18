#!/usr/bin/env ruby
# Encoding: utf-8
# Inspired by http://www.skorks.com/2011/02/a-unit-testing-framework-in-44-lines-of-ruby/

# Copyright (c) 2015, salesforce.com, inc. All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'open3'

# Main include file: entry point of your module
# Typically, the file you'd import in your application.
# By default: `@import 'module/<main.scss>';
$main_include_file ||= "index.scss"

# Where you'll write the Sass that will output the CSS
# to be parsed by your test suite
$test_file ||= "test/test.scss"

# If tests fail, check the compiled CSS in this file
# Ignore this file in versioning (e.g. add to .gitignore)
$test_error_file ||= "test/output.css"

$sass = Open3.capture3("node-sass #{$test_file} --stdout --output-style=compressed")
$output = $sass[0]
$errors = $sass[1]
puts "Running node-sass #{$test_file} --stdout --style compressed"
$global_failure_count = 0

module Kernel
  def describe(description, &block)
    tests = Dsl.new.parse(description, block)
    tests.execute
  end
  at_exit {
    begin
      if $global_failure_count > 0
        raise StandardError, "\n\e[31m✖ A total of #{$global_failure_count} test(s) failed.\e[0m\n\e[2mCompare #{$test_error_file} and the tests in test/travis.rb to find the errors.\e[0m"
      else
        puts "\n\e[1m\e[32m✓ All tests passed!\e[0m\e[0m"
      end
    rescue StandardError => e
      puts e.message
      exit 1
    end
  }
end
class Object
  def should
    self
  end
end
class Dsl
  def initialize
    @tests = {}
  end
  def parse(description, block)
    self.instance_eval(&block)
    Executor.new(description, @tests)
  end
  def it(description, &block)
    @tests[description] = block
  end
end
class Executor
  def initialize(description, tests)
    @description = description
    @tests = tests
    @success_count = 0
    @failure_count = 0
  end
  def execute
    puts "\n\e[1m#{@description}\e[0m"
    @tests.each_pair do |name, block|
      result = self.instance_eval(&block)
      puts result ? "\e[32m✓ #{name} \e[0m" : "\e[31m✖ #{name} \e[0m"
      result ? @success_count += 1 : @failure_count += 1
      result ? true : $global_failure_count += 1
    end
    summary
  end
  def summary
    puts "#{@tests.keys.size} tests, #{@success_count} success, #{@failure_count} failure"

    if @failure_count > 0
      stdout, stderr, status = Open3.capture3 "node-sass #{$test_file} #{$test_error_file} --include-path bower_components"
    end
  end
end

class String
  # squish method borrowed from Rails that removes newlines and extra spaces
  def squish
    strip.gsub /\s+/, ' '
  end
  # Load the module and compile to CSS
  def sass_to_css
    Open3.pipeline_r(['echo', ["@import '#{$main_include_file}';", self].join], ['node-sass --include-path bower_components']) do |output|
      output.read
    end
  end
end

# Test if a string appears in a multi-line output
def find(needle, haystack = $output)
  haystack.squish.include? needle.squish
end
