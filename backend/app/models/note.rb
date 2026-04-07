class Note < ApplicationRecord
  belongs_to :notebook
  has_one :user, through: :notebook
  has_many_attached :images
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  validates :title, presence: true

  default_scope { order(updated_at: :desc) }

  def self.search(query)
    where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%")
  end

  def touch_accessed!
    update_column(:accessed_at, Time.current)
  end
end
