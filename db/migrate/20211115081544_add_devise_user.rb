class AddDeviseUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      # Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      # Rememberable
      t.datetime :remember_created_at
    end
  end
end
