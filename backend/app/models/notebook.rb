class Notebook < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :destroy

  validates :name, presence: true

  scope :ordered_for_sidebar, -> { order(favorite: :desc, updated_at: :desc) }
end
