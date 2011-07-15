module CdfTable

  def default_poa_columns(t)
    t.string :record_code, :limit => 2
    t.string :sequence_number, :limit => 5
    t.string :po_number, :limit => 22
    t.timestamps
  end

  def default_inv_columns(t)
    t.string :record_code, :limit => 2
    t.string :sequence, :limit => 5
    t.integer :invoice_number
    t.timestamps
    t.references :cdf_invoice_file
  end
end