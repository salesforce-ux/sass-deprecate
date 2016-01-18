#!/usr/bin/env ruby
# Encoding: utf-8

# Copyright (c) 2015, salesforce.com, inc. All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require_relative 'test-framework'
require 'fileutils'

describe "Compiling files containing deprecated code" do
  stdout, stderr, status = Open3.capture3 "node-sass test/error.scss test/error.css"
  puts "Running node-sass test/error.scss test/error.css"

  it "should fail to compile" do
    not status.success? and
    not File.exist? 'test/error.css'
  end
  it "should throw a useful error message" do
    find "Deprecated code was found: please remove it to continue.", stderr
  end
end

describe "Signaling deprecated code for a future patch" do
  it "output the deprecated code" do
    find ".deprecate-in-next-patch{content"
  end
  it "should throw warnings" do
    find ".deprecate-in-next-patch will be deprecated in 1.0.1. Current version: 1.0.0.", $errors
  end
end

describe "Signaling deprecated code for a future major version" do
  it "output the deprecated code" do
    find ".deprecate-in-next-minor-version{content"
  end
  it "should throw warnings" do
    find ".deprecate-in-next-minor-version will be deprecated in 1.1.0. Current version: 1.0.0.", $errors
  end
end

describe "Signaling deprecated code for a future major version" do
  it "output the deprecated code" do
    find ".deprecate-in-next-major-version{content"
  end
  it "should throw warnings" do
    find ".deprecate-in-next-major-version will be deprecated in 2.0.0. Current version: 1.0.0.", $errors
  end
end

describe "Giving a reason for deprecation" do
  it "should surface the reason in console warnings" do
    find "That's the reason.", $errors
  end
end
