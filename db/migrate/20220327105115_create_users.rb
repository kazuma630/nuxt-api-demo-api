class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false, comment: 'ユーザー名'
      t.string :email, null: false, comment: 'メールアドレス'
      t.string :password_digest, null: false, comment: 'パスワード'
      t.boolean :activated_flg, null: false, default: false, comment: '認証フラグ'
      t.boolean :admin_flg, null: false, default: false, comment: '管理ユーザーフラグ'
      t.timestamps
    end
  end
end
