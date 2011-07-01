class Manager

  def generate_po
    po_file = PoFile.new
    po_file.save_data!
    po_file
  end



end