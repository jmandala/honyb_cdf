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


  def self.import(opt = :log_error)
    imported = []
    self.needs_import.select do |importable|
      begin
        importable.import
      rescue StandardError => e
        logger.error "Failed to import: #{importable.file_name}: #{importable.data}"
        logger.error e

        raise e if opt == :die_on_error
      end

      imported << importable
    end
    imported
  end

  def self.import!
    self.import(:die_on_error)
  end

end