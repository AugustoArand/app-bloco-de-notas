class Tag < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "já existe para este usuário" }
  validates :color, presence: true

  default_scope { order(:name) }
end
