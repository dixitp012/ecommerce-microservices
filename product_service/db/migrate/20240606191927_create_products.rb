class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name
      t.text :description
      t.monetize :price
      t.string :currency
      t.boolean :active

      t.timestamps
    end
  end
end
