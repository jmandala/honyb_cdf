module PoaRecord
  # To change this template use File | Settings | File Templates.
  extend ActiveModel::Naming


  def find_self(poa_order_header, sequence_number)
    self.where(:poa_order_header_id => poa_order_header, :sequence_number => sequence_number).first
  end

  def find_self!(poa_order_header, sequence_number)
    object = self.find_self(poa_order_header, sequence_number)
    return object unless object.nil?

    self.create(:poa_order_header => poa_order_header, :sequence_number => sequence_number)
  end

  def find_or_create(data, poa_file)
    order = Order.find_by_po_number!(data[:po_number])
    poa_order_header = PoaOrderHeader.find_self(order, poa_file)

    self.find_self!(poa_order_header, data[:sequence_number])
  end

  def populate(p, poa_file, section = self.model_name.i18n_key)
    return if p.nil? || p[section].nil?
    p[section].each do |data|
      object = self.find_or_create(data, poa_file)
      object.update_from_hash(data)
      begin
        object.send(:after_populate, data)
      rescue NameError => e
        end
      object
    end
  end

end