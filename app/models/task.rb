# frozen_string_literal: true

# Task model
class Task < Sequel::Model
  one_to_one :document
end
