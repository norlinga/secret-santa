# frozen_string_literal: true

require 'faker'

require_relative 'app'

# Let's test the performance of the secret santa pairing algorithm
# by creating a large number of gifters and running the algorithm
# a large number of times to get a median and average number of
# attempts to pair gifters.

i = 100 # creates double the number of gifters
gifters = []

i.times do
  name1 = Faker::Name.unique.name
  name2 = Faker::Name.unique.name

  gifters << { name: name1, email: Faker::Internet.email, exclude: [name2] }
  gifters << { name: name2, email: Faker::Internet.email, exclude: [name1] }
end

secret_santa = SecretSanta.new(gifters: gifters)

j = 10_000

attempts = []

j.times do
  secret_santa.instance_variable_set(:@attempts, 0)
  secret_santa.pair_gifters
  attempts << secret_santa.attempts
end

median = attempts.sort[(attempts.length - 1) / 2]
average = attempts.sum / attempts.length.to_f

puts "Median: #{median}"
puts "Average: #{average}"