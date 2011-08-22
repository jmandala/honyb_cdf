module CdfInvoiceRecord
  include Updateable

  def self.included(base)
    base.extend ActiveModel::Naming
    base.extend ClassMethods
  end

  module ClassMethods
    def find_self(cdf_invoice_file, sequence)
      self.where(:cdf_invoice_file_id => cdf_invoice_file.id, :sequence => sequence).first
    end

    def find_self!(cdf_invoice_file, sequence)
      object = self.find_self(cdf_invoice_file, sequence)
      return object unless object.nil?

      self.create(:cdf_invoice_file_id => cdf_invoice_file.id, :sequence => sequence)
    end

    def find_or_create(data, cdf_invoice_file)
      self.find_self!(cdf_invoice_file, data[:sequence])
    end

    def populate(p, cdf_invoice_file, section = self.model_name.i18n_key)
      return if p.nil? || p[section].nil?
      p[section].each do |data|
        object = self.find_or_create(data, cdf_invoice_file)
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