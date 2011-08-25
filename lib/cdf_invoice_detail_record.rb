module CdfInvoiceDetailRecord
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def find_nearest_before(cdf_invoice_file, line_number)
      find_nearest cdf_invoice_file, line_number, :before      
    end

    def find_nearest_before!(cdf_invoice_file, line_number)
      find_nearest!(cdf_invoice_file, line_number, :before)
    end

    def find_nearest!(cdf_invoice_file, line_number, where=:before)
      if where == :before
        nearest = find_nearest_before cdf_invoice_file, line_number
      else 
        nearest = find_nearest_after cdf_invoice_file, line_number
      end         
      
      return nearest if !nearest.nil?
      raise_error cdf_invoice_file, line_number
    end

    def find_nearest_after(cdf_invoice_file, line_number)
      find_nearest cdf_invoice_file, line_number, :after
    end

    def find_nearest(cdf_invoice_file, line_number, where=:before)
      if where == :before
        relative_to = '<'
      elsif where == :after
        relative_to = '>'
      else
        raise ArgumentError, "illegal argument specified for where: #{where}"
      end
      
      where(:cdf_invoice_file_id => cdf_invoice_file.id).
          where("line_number #{relative_to} :line_number", {:line_number => line_number}).
          order("sequence_number DESC").
          limit(1).first
    end

    def find_nearest_after!(cdf_invoice_file, line_number)
      nearest = find_nearest_after cdf_invoice_file, line_number
      return nearest if !nearest.nil?
      raise_error cdf_invoice_file, line_number
    end


    def raise_error(cdf_invoice_file, line_number)
      raise ActiveRecord::RecordNotFound, "Expected to find #{name} with cdf_invoice_file.id = #{cdf_invoice_file.id}, and line_number < #{line_number}"
    end
  end
end