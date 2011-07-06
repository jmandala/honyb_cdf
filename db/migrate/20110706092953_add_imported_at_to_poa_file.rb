class AddImportedAtToPoaFile < ActiveRecord::Migration
  def self.up
    add_column :poa_files, :imported_at, :datetime
  end

  def self.down
    remove_column :poa_files, :imported_at
  end
end
