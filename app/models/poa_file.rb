#noinspection RailsParamDefResolve
require 'net/ftp'

class PoaFile < ActiveRecord::Base
  #noinspection RubyResolve
  include Importable

  has_many :poa_order_headers, :dependent => :destroy, :autosave => true
  has_one :poa_file_control_total, :dependent => :destroy, :autosave => true
  belongs_to :poa_type
  belongs_to :po_file
  has_many :orders, :through => :poa_order_headers

  collaborator PoaOrderHeader
  collaborator PoaVendorRecord
  collaborator PoaShipToName
  collaborator PoaAddressLine
  collaborator PoaCityStateZip
  collaborator PoaLineItem
  collaborator PoaAdditionalDetail
  collaborator PoaLineItemTitleRecord
  collaborator PoaLineItemPubRecord
  collaborator PoaItemNumberPriceRecord
  collaborator PoaOrderControlTotal
  collaborator PoaFileControlTotal

  @@ext = '.fbc'
  file_mask "/*@@ext"

  import_format do |d|
    d.template :poa_defaults do |t|
      t.record_code 2
      t.sequence_number 5
    end

    d.template :poa_defaults_plus do |t|
      t.record_code 2
      t.sequence_number 5
      t.po_number 22
    end

    d.header(:align => :left) do |h|
      h.trap { |line| line[0, 2] == '02' }
      h.template :poa_defaults
      h.file_source_san 7
      h.spacer 5
      h.file_source_name 13
      h.poa_creation_date 6
      h.electronic_control_unit 5
      h.file_name 17
      h.format_version 3
      h.destination_san 7
      h.spacer 5
      h.poa_type 1
      h.spacer 4
    end

  end

  def populate_file_header(p)
    header = p[:header].first
    header[:poa_type_id] = PoaType.find_by_code(header[:poa_type]).try(:id)
    po_file = PoFile.find_by_file_name(p[:file_name])
    update_from_hash header, :excludes => [:file_name]
    logger.warn "PO File could not be found with name: '#{p[:file_name]}'" if po_file.nil?
  end

  def self.create_path(file_name)
    File.join CdfConfig::current_data_lib_in, file_name
  end

  def self.remote_files
    files = []
    self.connect do |ftp|
      ftp.chdir 'outgoing'
      files = self.poa_files(ftp)
    end
    files
  end

  def self.poa_files(ftp)
    files = []

    ftp.list do |file|
      file_name = file.split[file.split.length-1]
      if file_name =~ /#{@@ext}$/
        files << file_name
      end
    end
    files
  end

  def self.retrieve_count
    remote_files.size
  end

  def self.connect
    if !block_given?
      raise ArgumentError.new('Need to pass a block to self#connect')
    end

    Net::FTP.open(Spree::Config[:cdf_ftp_server]) do |ftp|
      ftp.login Spree::Config[:cdf_ftp_user], Spree::Config[:cdf_ftp_password]

      yield ftp

    end

  end

  def self.retrieve
    CdfConfig::ensure_path CdfConfig::current_data_lib_in

    files = []
    self.connect do |ftp|
      ftp.chdir 'outgoing'

      self.poa_files(ftp).each do |file|
        logger.debug "Remote: #{file}"
        file_name = file.split[file.split.length-1]
        path = create_path file_name

        logger.debug "Downloading #{file_name} -> #{path}"
        ftp.gettextfile(file_name, path)
        logger.debug 'Downloading complete'

        # to do: Error if file already exists
        files << self.find_or_create_by_file_name(file_name)
        logger.debug 'done poafile create'
      end
      logger.debug 'done list'
    end

    logger.debug 'done'

    files
  end

  def self.needs_import
    where("poa_files.imported_at IS NULL")
  end

  def self.import
    self.needs_import.select do |importable|
      importable.import
      importable
    end
  end

end