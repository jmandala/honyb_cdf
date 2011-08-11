module PoaRecord
  include Records
  extend ActiveModel::Naming

  def find_self(poa_file, sequence_number)
    sequence_number.strip! unless sequence_number.nil?
    joins(:poa_order_header => :poa_file).
        where('poa_files.id' => poa_file.id, :sequence_number => sequence_number).
        readonly(false).
        first
  end

  
  def find_or_create(data, poa_file)
    object = find_self poa_file, data[:sequence_number]
    return object unless object.nil?

    order = Order.find_by_number!(data[:po_number].strip!)
    poa_order_header = PoaOrderHeader.find_self(order, poa_file)
    create(:poa_order_header_id => poa_order_header.id, :sequence_number => data[:sequence_number])
  end

  def populate(p, poa_file, section = self.model_name.i18n_key)
    return if p.nil? || p[section].nil?
    p[section].each do |data|
      object = find_or_create(data, poa_file)
      begin
        object.send(:before_populate, data)
      rescue NameError => e
      end

      object.update_from_hash(data)

      object
    end
  end

end