class User < ApplicationRecord
  # bcryptの有効化
  has_secure_password

  VALID_PASSWORD_LEGIX = /\A[\w\-]+\z/

  validates :name, presence: true, length: { maximum: 30, allow_blank: true }
  validates :email, presence: true
  validates :password, presence: true, length:  { minimum: 8, allow_blank: true }, 
                       format: { with: VALID_PASSWORD_LEGIX, message: :invalid_password, allow_blank: true }, allow_nil: true
  validates :activated_flg, inclusion: { in: [ true, false ] }
  validates :admin_flg, inclusion: { in: [ true, false ] }
end
