module AsnRecord
  extend ActiveModel::Naming

  def find_self(asn_file, order_id)
    self.where(:asn_file_id => asn_file.id, :order_id => order_id ).first
  end

  def find_self!(asn_file, order_id)
    object = self.find_self(asn_file, order_id)
    return object unless object.nil?

    self.create(:asn_file_id => asn_file.id, :order_id => order_id)
  end

  def find_or_create(data, asn_file)
    Rails.logger.debug "Client Order ID: #{data[:client_order_id]}"

    order_number = data[:client_order_id].strip!
    begin
      order = Order.find_by_po_number!(order_number)

    rescue Exception => e
      Rails.logger.error "No order with ID #{order_number}"
      order = Order.create(:number => order_number)
    end

    self.find_self!(asn_file, order.id)
  end

  def populate(p, asn_file, section = self.model_name.i18n_key)
    return if p.nil? || p[section].nil?
    p[section].each do |data|
      object = self.find_or_create(data, asn_file)
      begin
        object.send(:before_populate, data)
      rescue NameError => e
      end

      object.update_from_hash(data)

      object
    end
  end

end