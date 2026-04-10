class QuickNote < ApplicationRecord
  belongs_to :user

  validates :color, inclusion: {
    in: %w[default purple green amber rose blue],
    message: "cor inválida"
  }

  default_scope { order(position: :asc, created_at: :desc) }
end
