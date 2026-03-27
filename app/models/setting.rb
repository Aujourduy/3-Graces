class Setting < ApplicationRecord
  # Singleton pattern - only one Setting record should exist
  def self.instance
    first_or_create!
  end
end
