#!/usr/bin/env ruby
# frozen_string_literal: true

# Test runner that executes the entire test suite
# Usage: ruby test/run.rb

# Set up load paths
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path(__dir__)

# Load test helper first (sets up minitest, reporters, etc.)
require_relative 'test_helper'

# Load all test files
test_files = Dir[File.join(__dir__, '*_test.rb')]

test_files.each do |test_file|
  require test_file
end

# Minitest::autorun (from test_helper.rb) will automatically run all loaded tests
