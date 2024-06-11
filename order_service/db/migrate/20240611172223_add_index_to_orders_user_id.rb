class AddIndexToOrdersUserId < ActiveRecord::Migration[7.1]
  def change
    def change
      add_index :orders, :user_id
    end
  end
end
