# frozen_string_literal: true

require_relative 'test_helper'
require 'tmpdir'
require 'fileutils'

# tests to validate PairingRecorder class
class PairingRecorderTest < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
    @recorder = PairingRecorder.new(base_dir: @temp_dir)

    @pairings = [
      [{ name: 'Alice', email: 'alice@example.com' }, { name: 'Bob', email: 'bob@example.com' }],
      [{ name: 'Bob', email: 'bob@example.com' }, { name: 'Charlie', email: 'charlie@example.com' }]
    ]
    @year = 2025
  end

  def teardown
    FileUtils.rm_rf(@temp_dir)
  end

  def test_creates_year_directory
    @recorder.save(@pairings, @year)

    assert Dir.exist?(File.join(@temp_dir, '2025'))
  end

  def test_returns_file_path
    file_path = @recorder.save(@pairings, @year)

    assert_includes file_path, @temp_dir
    assert_includes file_path, '2025'
    assert_includes file_path, 'pairings_'
    assert_includes file_path, '.txt'
  end

  def test_creates_file_with_pairings
    file_path = @recorder.save(@pairings, @year)

    assert File.exist?(file_path)
    content = File.read(file_path)

    assert_includes content, 'Secret Santa Pairings - 2025'
    assert_includes content, 'Alice'
    assert_includes content, 'Bob'
    assert_includes content, 'Charlie'
  end

  def test_file_includes_header
    file_path = @recorder.save(@pairings, @year)
    content = File.read(file_path)

    assert_includes content, 'Secret Santa Pairings - 2025'
    assert_includes content, 'Generated:'
    assert_includes content, '=' * 50
  end

  def test_file_includes_all_pairings
    file_path = @recorder.save(@pairings, @year)
    content = File.read(file_path)

    assert_includes content, 'Gift #1:'
    assert_includes content, 'Gift #2:'
    assert_includes content, 'Alice (alice@example.com) → Bob (bob@example.com)'
    assert_includes content, 'Bob (bob@example.com) → Charlie (charlie@example.com)'
  end

  def test_handles_multiple_saves_to_same_year
    file_path1 = @recorder.save(@pairings, @year)
    sleep 1 # Ensure different timestamp
    file_path2 = @recorder.save(@pairings, @year)

    refute_equal file_path1, file_path2
    assert File.exist?(file_path1)
    assert File.exist?(file_path2)
  end

  def test_uses_environment_variable_when_set
    ENV['PAIRINGS_DIR'] = @temp_dir
    recorder = PairingRecorder.new

    file_path = recorder.save(@pairings, @year)
    assert_includes file_path, @temp_dir
  ensure
    ENV.delete('PAIRINGS_DIR')
  end

  def test_file_naming_includes_timestamp
    file_path = @recorder.save(@pairings, @year)
    filename = File.basename(file_path)

    # Should match pattern: pairings_YYYYMMDD_HHMMSS.txt
    assert_match(/pairings_\d{8}_\d{6}\.txt/, filename)
  end

  def test_creates_nested_directories_if_needed
    deep_dir = File.join(@temp_dir, 'nested', 'dirs')
    recorder = PairingRecorder.new(base_dir: deep_dir)

    file_path = recorder.save(@pairings, @year)

    assert File.exist?(file_path)
  end
end
