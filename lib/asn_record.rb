module AsnRecord
  extend ActiveModel::Naming

  class InvalidOrderError < ActiveRecord::RecordNotFound
  end


  def find_self(asn_file, order_id)
    self.where(:asn_file_id => asn_file.id, :order_id => order_id).first
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

    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "No order with ID #{order_number}"
      raise InvalidOrderError.new("Could not import ASN for order number:#{order_number}")
    end

    self.find_self!(asn_file, order.id)
  end

  def populate(p, asn_file, section = self.model_name.i18n_key)
    return if p.nil? || p[section].nil?
    errors = []
    p[section].each do |data|

      begin
        object = self.find_or_create(data, asn_file)
        object.send(:before_populate, data)
        object.update_from_hash(data)

      rescue NameError => e
      rescue InvalidOrderError =>e
        errors << e
      end

    end
    errors
  end

end