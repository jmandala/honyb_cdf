class GeneratePoFiles < ActiveRecord::Migration
  def self.up
    create_table :po_files do |t|
      t.string :file_name, :limit => 22
      t.datetime :submitted_at
      t.timestamps
    end

    add_column :products, :po_file_id, :integer
  end

  def self.down
    drop_table :po_files
    remove_column :products, :po_file_id
  end
end
