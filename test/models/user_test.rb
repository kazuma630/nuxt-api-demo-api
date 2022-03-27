require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = active_user
  end

  test "name_validation" do
    # 入力必須チェック
    user = User.new(email: "test@example.com", password: "password")
    user.save
    required_msg = ["名前を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 文字数チェック（異常系）
    max = 30
    name = "a" * (max + 1)
    user.name = name
    user.save
    maxlength_msg = ["名前は30文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 文字数チェック（正常系）
    name = "あ" * max
    user.name = name
    assert_difference("User.count", 1) do
      user.save
    end
  end

  test "email_validation" do
    # 入力必須チェック
    user = User.new(name: "test", password: "password")
    user.save
    required_msg = ["メールアドレスを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 文字数チェック
    max = 255
    domain = "@example.com"
    email = "a" * ((max + 1) - domain.length) + domain
    user.email = email
    user.save
    maxlength_msg = ["メールアドレスは255文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック format = /\A\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\z/
    correct_emails = %w(
      A@EX.COM
      a-_@e-x.c-o_m.j_p
      a.a@ex.com
      a@e.co.js
      1.1@ex.com
      a.a+a@ex.com
    )
    correct_emails.each do |email|
      user.email = email
      assert user.save
    end

    # email小文字チェック
    email = "USER@EXAMPLE.COM"
    user = User.new(email: email)
    user.save
    assert user.email == email.downcase
  end

  test "active_user_uniqueness" do
    email = "test@example.com"

    # アクティブユーザーがいない場合、同じメールアドレスが登録できていること
    count = 3
    assert_difference("User.count", count) do
      count.times do |n|
        User.create(name: "test", email: email, password: "password")
      end
    end

    # ユーザーがアクティブになった場合、バリデーションエラーを吐くこと
    active_user = User.find_by(email: email)
    active_user.update!(activated_flg: true)

    assert_no_difference("User.count") do
      user = User.new(name: "test", email: email, password: "password")
      user.save
      uniqueness_msg = ["メールアドレスはすでに存在します"]
      assert_equal(uniqueness_msg, user.errors.full_messages)
    end

    # アクティブユーザーがいなくなった場合、ユーザーは保存できること
    active_user.destroy!
    assert_difference("User.count", 1) do
      User.create(name: "test", email: email, password: "password", activated_flg: true)
    end

    # 一意性は保たれていること
    assert_equal(1, User.where(email: email, activated_flg: true).count)
  end

  test "password_validation" do
    # 入力必須であること
    user = User.new(name: "test", email: "test@example.com")
    user.save
    required_msg = ["パスワードを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # min文字以上であること
    min = 8
    user.password = "a" * (min - 1)
    user.save
    minlength_msg = ["パスワードは8文字以上で入力してください"]
    assert_equal(minlength_msg, user.errors.full_messages)

    # max文字以下であること
    max = 72
    user.password = "a" * (max + 1)
    user.save
    maxlength_msg = ["パスワードは72文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック（正常系） VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
    correct_passwords = %w(
      pass---word
      ________
      12341234
      ____pass
      pass----
      PASSWORD
    )
    correct_passwords.each do |pass|
      user.password = pass
      assert user.save
    end
    
    # 書式チェック（正常系）
    incorrect_passwords = %w(
      pass/word
      pass.word
      |~=?+"a"
      password@
    )
    format_msg = ["パスワードは半角英数字、-、_のみ使用可能です"]
    incorrect_passwords.each do |pass|
      user.password = pass
      user.save
      assert_equal(format_msg, user.errors.full_messages)
    end
  end
end
