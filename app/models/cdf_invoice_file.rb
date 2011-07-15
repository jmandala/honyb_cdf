class CdfInvoiceFile < ActiveRecord::Base
  include Updateable

  has_many :orders, :through => :cdf_invoice_detail_totals
  has_many :cdf_invoice_detail_totals

  FixedWidth.define :cdf_invoice_file do |d|
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
      h.file_name 22
      h.spacer 20
    end

    CdfInvoiceHeader.spec d
    CdfInvoiceDetailTotal.spec d
    CdfInvoiceIsbnDetail.spec d
    CdfInvoiceEanDetail.spec d
    CdfInvoiceFreightAndFee.spec d
    CdfInvoiceTotal.spec d
    CdfInvoiceTrailer.spec d
    CdfInvoiceFileTrailer.spec d
  end


    # connect to remote server
    # retrieve all files
    # save to data_lib
    # create records for each file
  def self.download

  end

    # Read the file data and build the record
  def parsed
    FixedWidth.parse(File.new(path), :cdf_invoice_file)
  end


  def populate_file_header(p)
    update_from_hash p[:header].first
  end

  def import
    p = parsed
    populate_file_header(p)
    self.imported_at = Time.now
    save!
  end

  def path
    "#{CdfConfig::data_lib_in_root(created_at.strftime("%Y"))}/#{file_name}"
  end

  def data
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)

    return @data unless @data.nil? || @data.empty?

    @data = ''
    File.open(path, 'r') do |file|
      while line = file.gets
        @data << line
      end
    end
    @data
  end


end