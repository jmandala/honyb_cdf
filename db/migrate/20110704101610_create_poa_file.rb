class CreatePoaFile < ActiveRecord::Migration
  def self.up
    create_table 'poa_files', :force => true do |t|

      t.string    'record_code',       :limit => 2
      t.string    'sequence_number',   :limit => 5
      t.string    'file_source_san',   :limit => 7
      t.string    'file_source_name',  :limit => 13
      t.datetime  'poa_creation_date'
      t.string    'electronic_control_unit', :limit => 5
      t.string    'file_name',         :limit => 17
      t.string    'format_version',    :limit => 3
      t.string    'destination_san',   :limit => 7
      t.integer   'poa_type_id'
      t.timestamps
    end
  end

  def self.down
    drop_table 'poa_files'
  end
end
