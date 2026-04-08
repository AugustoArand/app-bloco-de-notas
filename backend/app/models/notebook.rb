class Notebook < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :destroy

  validates :name, presence: true

  default_scope { order(favorite: :desc, updated_at: :desc) }
end
