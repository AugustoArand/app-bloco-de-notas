class Note < ApplicationRecord
  belongs_to :notebook
  has_one :user, through: :notebook
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 1920, 1080 ]
  end
  has_many :note_tags, dependent: :destroy

  validates :images, content_type: { in: %w[image/jpeg image/png image/gif image/webp], message: "deve ser JPEG, PNG, GIF ou WebP" },
                     size: { less_than: 10.megabytes, message: "deve ter menos de 10MB" }
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
