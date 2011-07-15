class CdfInvoiceFile < ActiveRecord::Base
  include Importable

  has_many :orders, :through => :cdf_invoice_detail_totals
  has_many :cdf_invoice_detail_totals

  collaborator CdfInvoiceHeader
  collaborator CdfInvoiceDetailTotal
  collaborator CdfInvoiceIsbnDetail
  collaborator CdfInvoiceEanDetail
  collaborator CdfInvoiceFreightAndFee
  collaborator CdfInvoiceTotal
  collaborator CdfInvoiceTrailer
  collaborator CdfInvoiceFileTrailer

  import_format do |d|
    d.template :cdf_invoice_defaults do |t|
      t.record_code 2
      t.sequence 5
      t.invoice_number 8
    end

    d.header(:align => :left) do |h|
      h.trap { |line| line[0, 2] == '01' }
      h.record_code 2
      h.sequence 5
      h.ingram_san 12
      h.file_source 13
      h.creation_date 6
      h.ingram_file_name 22
      h.spacer 20
    end
  end

end