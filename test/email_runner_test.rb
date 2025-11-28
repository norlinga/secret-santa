# frozen_string_literal: true

require_relative 'test_helper'
require 'stringio'

# tests to validate EmailRunner class
class EmailRunnerTest < Minitest::Test
  # Simple stubs that don't need method mocking for initialization tests
  ConfigStub = Struct.new(:year, :organizer, :gift_amount)
  RecorderStub = Class.new

  def setup
    @config_stub = ConfigStub.new(2025, { 'name' => 'Alice', 'email' => 'alice@example.com' }, 75)
    @recorder_stub = RecorderStub.new
    @pairings = [
      [{ name: 'Alice', email: 'alice@example.com' }, { name: 'Bob', email: 'bob@example.com' }]
    ]
  end

  def setup_mocked_config
    @config = Minitest::Mock.new
    @config.expect :year, 2025
    @config.expect :organizer, { 'name' => 'Alice', 'email' => 'alice@example.com' }
    @config.expect :gift_amount, 75
  end

  def setup_mocked_recorder
    @recorder = Minitest::Mock.new
  end

  def capture_output
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  def test_initializes_with_config
    runner = EmailRunner.new(config: @config_stub)
    assert_equal @config_stub, runner.instance_variable_get(:@config)
  end

  def test_initializes_with_custom_recorder
    runner = EmailRunner.new(config: @config_stub, recorder: @recorder_stub)
    assert_equal @recorder_stub, runner.instance_variable_get(:@recorder)
  end

  def test_initializes_with_default_recorder_when_not_provided
    runner = EmailRunner.new(config: @config_stub)
    assert_instance_of PairingRecorder, runner.instance_variable_get(:@recorder)
  end

  def test_run_calls_recorder_save
    setup_mocked_config
    setup_mocked_recorder
    @recorder.expect :save, '/tmp/pairings.txt', [@pairings, 2025]

    runner = EmailRunner.new(config: @config, recorder: @recorder)

    # Mock the mailer to avoid actual email sending
    SantaMailer.stub :new, lambda { |*_args|
      mock_mailer = Minitest::Mock.new
      mock_mailer.expect :send_email, nil
      mock_mailer
    } do
      capture_output do
        runner.run(@pairings)
      end
    end

    @recorder.verify
  end

  def test_run_displays_start_message
    setup_mocked_config
    setup_mocked_recorder
    @recorder.expect :save, '/tmp/pairings.txt', [@pairings, 2025]
    runner = EmailRunner.new(config: @config, recorder: @recorder)

    SantaMailer.stub :new, lambda { |*_args|
      mock_mailer = Minitest::Mock.new
      mock_mailer.expect :send_email, nil
      mock_mailer
    } do
      output = capture_output do
        runner.run(@pairings)
      end

      assert_includes output, 'Sending emails'
    end
  end

  def test_run_displays_success_message
    setup_mocked_config
    setup_mocked_recorder
    @recorder.expect :save, '/tmp/pairings.txt', [@pairings, 2025]
    runner = EmailRunner.new(config: @config, recorder: @recorder)

    SantaMailer.stub :new, lambda { |*_args|
      mock_mailer = Minitest::Mock.new
      mock_mailer.expect :send_email, nil
      mock_mailer
    } do
      output = capture_output do
        runner.run(@pairings)
      end

      assert_includes output, 'All emails sent successfully'
    end
  end

  def test_run_displays_file_path
    setup_mocked_config
    setup_mocked_recorder
    file_path = '/tmp/test/pairings.txt'
    @recorder.expect :save, file_path, [@pairings, 2025]
    runner = EmailRunner.new(config: @config, recorder: @recorder)

    SantaMailer.stub :new, lambda { |*_args|
      mock_mailer = Minitest::Mock.new
      mock_mailer.expect :send_email, nil
      mock_mailer
    } do
      output = capture_output do
        runner.run(@pairings)
      end

      assert_includes output, file_path
    end
  end

  def test_run_displays_giver_names
    setup_mocked_config
    setup_mocked_recorder
    @recorder.expect :save, '/tmp/pairings.txt', [@pairings, 2025]
    runner = EmailRunner.new(config: @config, recorder: @recorder)

    SantaMailer.stub :new, lambda { |*_args|
      mock_mailer = Minitest::Mock.new
      mock_mailer.expect :send_email, nil
      mock_mailer
    } do
      output = capture_output do
        runner.run(@pairings)
      end

      assert_includes output, 'Alice'
    end
  end
end
