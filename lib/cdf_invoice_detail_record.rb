module CdfInvoiceDetailRecord
  include Updateable

  def self.included(base)
    base.extend ClassMethods

    base.class_eval do
      belongs_to :cdf_invoice_header
      has_one :cdf_invoice_file, :through => :cdf_invoice_header
    end

  end

  module ClassMethods

    def find_nearest_before(cdf_invoice_header, line_number)
      find_nearest cdf_invoice_header, line_number, :before
    end

    def find_nearest_before!(cdf_invoice_header, line_number)
      find_nearest!(cdf_invoice_header, line_number, :before)
    end

    def find_nearest!(cdf_invoice_header, line_number, where=:before)
      if where == :before
        nearest = find_nearest_before cdf_invoice_header, line_number
      else
        nearest = find_nearest_after cdf_invoice_header, line_number
      end

      return nearest if !nearest.nil?
      raise_error cdf_invoice_header, line_number
    end

    def find_nearest_after(cdf_invoice_header, line_number)
      find_nearest cdf_invoice_header, line_number, :after
    end

    def find_nearest(cdf_invoice_header, line_number, where=:before)
      if where == :before
        relative_to = '<'
      elsif where == :after
        relative_to = '>'
      else
        raise ArgumentError, "illegal argument specified for where: #{where}"
      end
      
      raise ArgumentError, "line_number must not be nil!" if line_number.nil?
      raise ArgumentError, "cdf_invoice_header must not be nil!" if cdf_invoice_header.nil?

      where(:cdf_invoice_header_id => cdf_invoice_header.id).
          where("line_number #{relative_to} :line_number", {:line_number => line_number}).
          order("line_number DESC").
          limit(1).first
    end

    def find_nearest_after!(cdf_invoice_header, line_number)
      nearest = find_nearest_after cdf_invoice_header, line_number
      return nearest if !nearest.nil?
      raise_error cdf_invoice_header, line_number
    end


    def raise_error(cdf_invoice_header, line_number)
      raise ActiveRecord::RecordNotFound, "Expected to find #{name} with cdf_invoice_header.id = #{cdf_invoice_header.id}, and line_number < #{line_number}"
    end

    def find_self(cdf_invoice_file, line_number)
      joins(:cdf_invoice_header => :cdf_invoice_file).
          where('cdf_invoice_files.id' => cdf_invoice_file.id, :line_number => line_number).
          readonly(false).
          first
    end

    def find_self!(cdf_invoice_file, line_number)
      object = self.find_self(cdf_invoice_file, line_number)
      return object unless object.nil?

      cdf_invoice_header = CdfInvoiceHeader.
          where(:cdf_invoice_file_id => cdf_invoice_file.id).
          where("line_number < ?", line_number).
          order('line_number DESC').
          limit(1).
          first

      create(:cdf_invoice_header_id => cdf_invoice_header.id, :line_number => line_number)
    end

    def find_or_create(data, cdf_invoice_file)
      find_self!(cdf_invoice_file, data[:__LINE_NUMBER__])
    end

    def populate(p, cdf_invoice_file, section = self.model_name.i18n_key)
      return if p.nil? || p[section].nil?
      p[section].each do |data|
        object = self.find_or_create(data, cdf_invoice_file)
        begin
          object.send(:before_populate, data) if object.respond_to? :before_populate
          object.send("line_number=", data[:__LINE_NUMBER__]) if object.respond_to? "line_number="
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