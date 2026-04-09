class AdminNotification < ApplicationRecord
  STATUSES = %w[non_lu lu valide archive].freeze
  CATEGORIES = %w[info warning error recurrence scraping crawl].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :category, inclusion: { in: CATEGORIES }

  scope :non_lu, -> { where(status: "non_lu") }
  scope :recent, -> { order(created_at: :desc) }

  def self.notify!(title:, message: nil, category: "info", source: nil, metadata: {})
    create!(title: title, message: message, category: category, source: source, metadata: metadata)
  end
end
