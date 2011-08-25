module CdfInvoiceDetailRecord
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def find_nearest(cdf_invoice_file, line_number)
      where(:cdf_invoice_file_id => cdf_invoice_file.id).
          where("line_number < :line_number", {:line_number => line_number}).
          order("sequence_number DESC").
          limit(1).first
    end

    def find_nearest!(cdf_invoice_file, line_number)
      nearest = find_nearest cdf_invoice_file, line_number
      return nearest if !nearest.nil?

      raise ActiveRecord::RecordNotFound, "Expected to find #{name} with cdf_invoice_file.id = #{cdf_invoice_file.id}, and line_number < #{line_number}"
    end

  end
end