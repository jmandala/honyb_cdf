class Manager

  def generate_po
    po_file = PoFile.new
    po_file.save!
    po_file.generate
    Rails.logger.debug po_file.data
    po_file.load_file
    po_file.data
    
  end



end