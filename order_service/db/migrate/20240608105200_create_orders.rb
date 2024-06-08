class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.uuid :user_id
      t.monetize :total

      t.timestamps
    end
  end
end
