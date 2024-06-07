class AddLockVersionToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :lock_version, :integer
  end
end
