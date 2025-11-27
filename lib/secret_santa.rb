# frozen_string_literal: true

# Provide an array of gifters as {name:, email:, exclude: []}
# to SecretSanta.new(gifters:)
# Then #pair_gifters will return an array of arrays of paired gifters
# as [[giver, receiver], [giver, receiver], ...]
class SecretSanta
  attr_reader :attempts

  def initialize(gifters:)
    @gifters = gifters
    @pairings = []
    @attempts = 0
  end

  def pair_gifters
    shuffle_gifters
    pairings_valid? ? @pairings : pair_gifters
  end

  private

  def shuffle_gifters
    @pairings = @gifters.zip(@gifters.shuffle)
  end

  def pairings_valid?
    @attempts += 1
    @pairings.all? do |giver, receiver|
      giver_name = giver[:name]
      receiver_name = receiver[:name]
      exclude_list = giver[:exclude]

      giver_name != receiver_name && !exclude_list.include?(receiver_name)
    end
  end
end
