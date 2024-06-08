class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.uuid :product_id
      t.integer :quantity
      t.monetize :price

      t.timestamps
    end
  end
end
