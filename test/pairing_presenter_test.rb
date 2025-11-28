# frozen_string_literal: true

require_relative 'test_helper'
require 'stringio'

# tests to validate PairingPresenter class
class PairingPresenterTest < Minitest::Test
  def setup
    @presenter = PairingPresenter.new
    @pairings = [
      [{ name: 'Alice', email: 'alice@example.com' }, { name: 'Bob', email: 'bob@example.com' }],
      [{ name: 'Charlie', email: 'charlie@example.com' }, { name: 'Diana', email: 'diana@example.com' }]
    ]
    @attempts = 5
  end

  def capture_output
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  def test_display_produces_output
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    refute_empty output
  end

  def test_display_includes_all_giver_names
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    assert_includes output, 'Alice'
    assert_includes output, 'Charlie'
  end

  def test_display_includes_all_receiver_names
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    assert_includes output, 'Bob'
    assert_includes output, 'Diana'
  end

  def test_display_includes_attempt_count
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    assert_includes output, '5 attempt(s)'
  end

  def test_display_includes_gift_numbers
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    assert_includes output, 'Gift #1'
    assert_includes output, 'Gift #2'
  end

  def test_display_includes_header
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    assert_includes output, 'Secret Santa Pairing Results'
  end

  def test_display_includes_decorative_elements
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    assert_includes output, '🎄'
    assert_includes output, '🎁'
  end

  def test_display_shows_arrow_between_giver_and_receiver
    output = capture_output do
      @presenter.display(@pairings, @attempts)
    end

    # Should show some indication of pairing direction
    assert_match(/Alice.*→.*Bob/m, output) || assert_match(/Alice.*->.*Bob/m, output)
  end

  def test_handles_single_pairing
    single_pairing = [
      [{ name: 'Eve', email: 'eve@example.com' }, { name: 'Frank', email: 'frank@example.com' }]
    ]

    output = capture_output do
      @presenter.display(single_pairing, 1)
    end

    assert_includes output, 'Eve'
    assert_includes output, 'Frank'
    assert_includes output, 'Gift #1'
    refute_includes output, 'Gift #2'
  end

  def test_handles_many_pairings
    many_pairings = (1..10).map do |i|
      [{ name: "Giver#{i}", email: "giver#{i}@example.com" },
       { name: "Receiver#{i}", email: "receiver#{i}@example.com" }]
    end

    output = capture_output do
      @presenter.display(many_pairings, 100)
    end

    assert_includes output, 'Gift #1'
    assert_includes output, 'Gift #10'
    assert_includes output, 'Giver1'
    assert_includes output, 'Receiver10'
  end
end
