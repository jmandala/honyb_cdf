module AsnRecord
  include Updateable

  # Returns the [AsnShipment] from the same [AsnFile] with the sequence that is
  # closest to this record's sequence, without being greater
  def nearest_asn_shipment(line_number)
    AsnShipment.
        where(:asn_file_id => self.asn_file_id).
        where("line_number < :line_number", {:line_number => line_number}).
        order("line_number DESC").
        limit(1).first
  end


  def self.included(base)
    base.extend ActiveModel::Naming
    base.extend ClassMethods
  end

  module ClassMethods
    def find_self(asn_file, line_number)
      where(:asn_file_id => asn_file.id, :line_number => line_number).
          readonly(false).
          first
    end

    def find_or_create(data, asn_file)
      order_number = data[:client_order_id].strip!
      begin
        object = find_self(asn_file, data[:__LINE_NUMBER__])
        return object unless object.nil?

        order = Order.find_by_number!(order_number)

        create(:asn_file_id => asn_file.id, :order_id => order.id)

      rescue ActiveRecord::RecordNotFound => e
        puts "No order with ID #{order_number}"
        Rails.logger.error "No order with ID #{order_number}"
        raise ActiveRecord::RecordNotFound, "Could not import ASN for order number:#{order_number}"
      end
    end

    def populate(p, asn_file, section = self.model_name.i18n_key)
      return if p.nil? || p[section].nil?
      objects = []
      p[section].each do |data|
        object = find_or_create(data, asn_file)
        begin
          object.send(:before_populate, data) if object.respond_to? :before_populate
          object.send("line_number=", data[:__LINE_NUMBER__]) if object.respond_to? "line_number="
        rescue => e
          puts e.message
          puts data.to_yaml
          raise e
        end

        object.update_from_hash(data)
        objects << object
      end
      objects

    end

  end
end