class CreatePoTypes < ActiveRecord::Migration
  def self.up
    create_table :po_types do |t|
      t.integer :code
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :po_types
  end
end
