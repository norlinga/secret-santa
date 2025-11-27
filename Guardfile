# frozen_string_literal: true

clearing :on

guard :minitest, all_after_pass: true do
  # Watch test files
  watch(%r{^test/(.*)_test\.rb$})

  # Watch lib files and run corresponding tests
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }

  # Watch app.rb and run all tests
  watch('app.rb') { 'test' }
end
