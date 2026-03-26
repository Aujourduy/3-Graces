class Newsletter < ApplicationRecord
  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "n'est pas valide" }

  # Callbacks
  before_create :set_consent_timestamp

  # Scopes
  scope :actifs, -> { where(actif: true) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def set_consent_timestamp
    self.consenti_at ||= Time.current
  end
end
