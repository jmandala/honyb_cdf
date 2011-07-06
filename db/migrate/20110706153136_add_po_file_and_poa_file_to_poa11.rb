class AddPoFileAndPoaFileToPoa11 < ActiveRecord::Migration
  def self.up
    add_column :poa_11_s, :po_file, :integer
    add_column :poa_11_s, :poa_file, :integer
  end

  def self.down
    remove_column :poa_11_s, :poa_file
    remove_column :poa_11_s, :po_file
  end
end
