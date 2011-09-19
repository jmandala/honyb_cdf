#noinspection RailsParamDefResolve
require 'net/ftp'

class PoaFile < ActiveRecord::Base
  #noinspection RubyResolve
  include Importable
  include Records

  has_many :poa_order_headers, :dependent => :destroy, :autosave => true
  has_one :poa_file_control_total, :dependent => :destroy, :autosave => true
  has_many :orders, :through => :poa_order_headers

  belongs_to :poa_type
  belongs_to :po_file

  has_many :versions, :class_name => 'PoaFile', :foreign_key => 'parent_id', :autosave => true
  belongs_to :parent, :class_name => 'PoaFile'

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

  define_ext 'fbc'
  define_length 80

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
    if !p.key?(:header)
      raise ArgumentError, "Invalid file data. Expected ':header'. Got: #{self.data}"
    end
    header = p[:header].first
    self.class.as_cdf_date header, :poa_creation_date
    self.poa_type = PoaType.find_by_code!(header[:poa_type])
    self.po_file = PoFile.find_by_file_name!(header[:file_name].downcase!)
    update_from_hash header, :excludes => [:file_name]
  end

end