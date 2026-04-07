class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :notebooks, dependent: :destroy
  has_many :notes, through: :notebooks
  has_many :tags, dependent: :destroy

  validates :name, presence: true

  def jwt_payload
    super.merge('name' => name, 'email' => email)
  end
end
