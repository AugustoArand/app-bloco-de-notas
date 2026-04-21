class Note < ApplicationRecord
  belongs_to :notebook
  has_one :user, through: :notebook
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 1920, 1080 ]
  end
  has_many :note_tags, dependent: :destroy

  has_many :tags, through: :note_tags

  validate :validate_image_attachments

  validates :title, presence: true

  default_scope { order(updated_at: :desc) }

  def self.search(query)
    where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%")
  end

  def touch_accessed!
    update_column(:accessed_at, Time.current)
  end

  private

  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  def validate_image_attachments
    images.each do |image|
      unless ALLOWED_IMAGE_TYPES.include?(image.blob.content_type)
        errors.add(:images, "deve ser JPEG, PNG, GIF ou WebP")
      end
      if image.blob.byte_size > 10.megabytes
        errors.add(:images, "deve ter menos de 10MB")
      end
    end
  end
end
