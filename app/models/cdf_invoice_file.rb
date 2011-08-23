class CdfInvoiceFile < ActiveRecord::Base
  include Importable
  include Records

  has_many :orders, :through => :cdf_invoice_detail_totals
  has_many :cdf_invoice_detail_totals


  has_many :versions, :class_name => CdfInvoiceFile.name, :foreign_key => 'parent_id', :autosave => true
  belongs_to :parent, :class_name => CdfInvoiceFile.name

  collaborator CdfInvoiceHeader
  collaborator CdfInvoiceDetailTotal
  collaborator CdfInvoiceIsbnDetail
  collaborator CdfInvoiceEanDetail
  collaborator CdfInvoiceFreightAndFee
  collaborator CdfInvoiceTotal
  collaborator CdfInvoiceTrailer
  collaborator CdfInvoiceFileTrailer

  define_ext '.BIN'
  define_length 80

  import_format do |d|
    d.template :cdf_invoice_defaults do |t|
      t.record_code 2
      t.sequence_number 5
      t.invoice_number 8
    end

    d.header(:align => :left) do |h|
      h.trap { |line| line[0, 2] == '01' }
      h.record_code 2
      h.sequence_number 5
      h.ingram_san 12
      h.file_source 13
      h.creation_date 6
      h.ingram_file_name 22
      h.spacer 20
    end
  end

  def populate_file_header(p)
    if !p.key?(:header)
      raise ArgumentError, "Invalid file data. Expected ':header'. Got: #{self.data}"
    end
    header = p[:header].first

    self.class.as_cdf_date header, :creation_date
    update_from_hash header
  end
end