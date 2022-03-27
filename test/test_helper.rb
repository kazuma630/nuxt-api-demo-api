ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  parallelize_setup do |worker|
    load "#{Rails.root}/db/seeds.rb"
  end
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  def active_user
    User.find_by(activated_flg: true)
  end
end
