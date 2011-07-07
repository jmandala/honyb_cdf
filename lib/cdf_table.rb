module CdfTable

  def default_poa_columns(t)
    t.string :record_code, :limit => 2
    t.string :sequence_number, :limit => 5
    t.string :po_number, :limit => 22
    t.timestamps
  end

end