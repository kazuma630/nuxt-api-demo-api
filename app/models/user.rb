require "validator/email_validator"

class User < ApplicationRecord
  before_validation :downcase_email
  # bcryptの有効化
  has_secure_password

  VALID_PASSWORD_LEGIX = /\A[\w\-]+\z/

  validates :name, presence: true, length: { maximum: 30, allow_blank: true }
  validates :email, presence: true, email: { allow_blank: true }
  validates :password, presence: true, length:  { minimum: 8, allow_blank: true }, 
                       format: { with: VALID_PASSWORD_LEGIX, message: :invalid_password, allow_blank: true }, allow_nil: true
  validates :activated_flg, inclusion: { in: [ true, false ] }
  validates :admin_flg, inclusion: { in: [ true, false ] }

  class << self
    def find_by_activated(email)
      find_by(email: email, activated_flg: true)
    end
  end

  def email_activated?
    users = User.where.not(id: id)
    users.find_by_activated(email).present?
  end

  private

  def downcase_email
    self.email.downcase! if email
  end
end
