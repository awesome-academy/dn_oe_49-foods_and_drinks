class RemoveRememberDigestFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :remember_digest, :string
  end
end
