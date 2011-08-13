module AsnRecord
  include Updateable

  def self.included(base)
    base.extend ClassMethods
    base.extend Records
    base.extend ActiveModel::Naming
  end

  module ClassMethods

    def find_self(asn_file, client_order_id)
      where(:asn_file_id => asn_file.id, :po_number => client_order_id.strip).first
    end

    def find_or_create(data, asn_file)
      order_number = data[:client_order_id].strip!
      begin
        object = find_self(asn_file, order_number)
        return object unless object.nil?

        order = Order.find_by_number!(order_number).first

        create(:asn_file_id => asn_file.id, :order_id => order.id)

      rescue ActiveRecord::RecordNotFound => e
        puts "No order with ID #{order_number}"
        Rails.logger.error "No order with ID #{order_number}"
        raise ActiveRecord::RecordNotFound, "Could not import ASN for order number:#{order_number}"
      end
    end

    def populate(p, asn_file, section = self.model_name.i18n_key)
      return if p.nil? || p[section].nil?
      p[section].each do |data|
        object = find_or_create(data, asn_file)
        begin
          object.send(:before_populate, data) if object.respond_to? :before_populate
        rescue => e
          puts e.message
          puts data.to_yaml
          raise e
        end

        object.update_from_hash(data)

        object
      end
    end

  end
end