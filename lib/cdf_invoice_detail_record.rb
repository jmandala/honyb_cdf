module CdfInvoiceDetailRecord
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def find_nearest(cdf_invoice_file, sequence_number)
      where(:cdf_invoice_file_id => cdf_invoice_file.id).
          where("sequence_number < :sequence_number", {:sequence_number => sequence_number}).
          order("sequence_number DESC").
          limit(1).first
    end

    def find_nearest!(cdf_invoice_file, sequence_number)
      nearest = find_nearest cdf_invoice_file, sequence_number
      return nearest if !nearest.nil?

      raise ActiveRecord::RecordNotFound, "Expected to find #{name} with cdf_invoice_file.id = #{cdf_invoice_file.id}, and sequence_number < #{sequence_number}"
    end

  end
end