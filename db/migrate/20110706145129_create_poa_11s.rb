class CreatePoa11s < ActiveRecord::Migration
  def self.up
    create_table :poa_11s do |t|
      t.string    'record_code',       :limit => 2
      t.string    'sequence_number',   :limit => 5
      t.string    'toc',               :limit => 13
      t.string    'po_number',         :limit => 22
      t.string    'icg_ship_to_account_number', :limit => 7
      t.string    'icg_san',           :limit => 7
      t.integer   'po_status_id'
      t.date      'acknowledgement_date'
      t.date      'po_date'
      t.date      'po_cancellation_date'
      t.timestamps
    end
  end

  def self.down
    drop_table :poa_11s
  end
end
