#!/usr/bin/env ruby
# Encoding: utf-8

# Copyright (c) 2015-2016, salesforce.com, inc. All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require_relative 'test-framework'
require 'fileutils'

describe "Compiling files with syntax errors" do
  stdout, stderr, status = Open3.capture3 "node-sass test/wrong-parameter-type.scss test/wrong-parameter-type.css"
  puts "Running node-sass test/wrong-parameter-type.scss test/wrong-parameter-type.css"

  it "should fail to compile if the parameter is not a string" do
    not status.success? and
    not File.exist? 'test/wrong-parameter-type.css'
  end

  it "should throw a useful error message" do
    find "The parameter passed to deprecate() must be a String.", stderr
  end
end

describe "Compiling files containing deprecated code" do
  stdout, stderr, status = Open3.capture3 "node-sass test/fail.scss test/fail.css"
  puts "Running node-sass test/fail.scss test/fail.css"

  it "should fail to compile if mode is set to fail" do
    not status.success? and
    not File.exist? 'test/fail.css'
  end
  it "should throw a useful error message" do
    # When compiling fail.scss
    find "Deprecated code was found. Remove it to continue.", stderr and
    # Warn but don't fail compilation of test.scss
    find "Deprecated code was found, it should be removed before its release.", $errors
  end
  it "should not output deprecated code" do
    not find ".deprecated"
  end
end

describe "Signaling deprecated code for a future patch" do
  it "should output the code" do
    find ".deprecate-in-next-patch{content"
  end
  it "should not throw any warnings" do
    not find "10.0.1", $errors
  end
end

describe "Signaling deprecated code for a future major version" do
  it "should output the code" do
    find ".deprecate-in-next-minor-version{content"
  end
  it "should not throw any warnings" do
    not find "10.1.0", $errors
  end
end

describe "Signaling deprecated code for a future major version" do
  it "should output the code" do
    find ".deprecate-in-next-major-version{content"
  end
  it "should not throw any warnings" do
    not find "11.0.0", $errors
  end
end

describe "Giving a reason for deprecation" do
  it "should surface the reason in console warnings" do
    find "Because reasons", $errors
  end
end

describe "Disabling the plugin" do
  it "should output deprecated code regardless" do
    find ".test-disabled-mode"
  end
  it "should not throw any warnings" do
    not find ".test-disabled-mode", $errors
  end
end

describe "Activating verbose mode" do
  it "should surface more information in console warnings" do
    find ".deprecate-verbose will be deprecated in 12.0.0. Current version: 10.0.0.", $errors and
    find "Some code will be deprecated in 12.0.0. Current version: 10.0.0.", $errors
  end
end
