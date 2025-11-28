# frozen_string_literal: true

require_relative 'test_helper'

# tests to validate SecretSanta class
class SecretSantaTest < Minitest::Test
  def setup
    @gifters = [
      { name: 'Alice', email: 'alice@example.com', exclude: ['Bob'] },
      { name: 'Bob', email: 'bob@example.com', exclude: ['Alice'] },
      { name: 'Charlie', email: 'charlie@example.com', exclude: ['Diana'] },
      { name: 'Diana', email: 'diana@example.com', exclude: ['Charlie'] },
      { name: 'Eve', email: 'eve@example.com', exclude: ['Frank'] },
      { name: 'Frank', email: 'frank@example.com', exclude: ['Eve'] }
    ]

    @valid_pairings = [
      [{ name: 'Alice', email: '', exclude: ['Bob'] },
       { name: 'Charlie', email: '', exclude: ['Diana'] }],
      [{ name: 'Bob', email: '', exclude: ['Alice'] },
       { name: 'Diana', email: '', exclude: ['Charlie'] }]
    ]

    @invalid_pairing_one = [
      [{ name: 'Alice', email: '', exclude: ['Bob'] },
       { name: 'Alice', email: '', exclude: ['Bob'] }],
      [{ name: 'Bob', email: '', exclude: ['Alice'] },
       { name: 'Charlie', email: '', exclude: ['Diana'] }]
    ]

    @invalid_pairing_two = [
      [{ name: 'Alice', email: '', exclude: ['Bob'] },
       { name: 'Bob', email: '', exclude: ['Alice'] }],
      [{ name: 'Bob', email: '', exclude: ['Alice'] },
       { name: 'Charlie', email: '', exclude: ['Diana'] }]
    ]
  end

  def test_new_requires_gifter_array
    assert_raises ArgumentError do
      SecretSanta.new
    end
  end

  def test_suffle_gifters_returns_array_of_arrays
    secret_santa = SecretSanta.new(gifters: @gifters)
    assert_equal Array, secret_santa.send(:shuffle_gifters).class
    assert !secret_santa.instance_variable_get(:@pairings).nil?
  end

  def test_pairings_valid_returns_true_for_valid_pairings
    secret_santa = SecretSanta.new(gifters: @gifters)
    secret_santa.instance_variable_set(:@pairings, @valid_pairings)
    assert secret_santa.send(:pairings_valid?)
  end

  def test_pairings_valid_returns_false_for_invalid_pairings
    secret_santa = SecretSanta.new(gifters: @gifters)
    secret_santa.instance_variable_set(:@pairings, @invalid_pairing_one)
    assert !secret_santa.send(:pairings_valid?)
    secret_santa.instance_variable_set(:@pairings, @invalid_pairing_two)
    assert !secret_santa.send(:pairings_valid?)
  end
end
