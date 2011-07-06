class ChangeDatesOnPoa11s < ActiveRecord::Migration
  def self.up
    change_column :poa_11, :acknowledgement_date, :datetime
    change_column :poa_11, :po_date, :datetime
    change_column :poa_11, :po_cancellation_date, :datetime
  end

  def self.down
    change_column :poa_11, :acknowledgement_date, :date
    change_column :poa_11, :po_date, :date
    change_column :poa_11, :po_cancellation_date, :date
  end
end
