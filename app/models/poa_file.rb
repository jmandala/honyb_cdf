class PoaFile < ActiveRecord::Base
  include Updateable

  has_many :poa_order_headers, :dependent => :destroy, :autosave => true
  has_one :poa_file_control_total, :dependent => :destroy, :autosave => true
  belongs_to :poa_type
  belongs_to :po_file

    # connect to remote server
    # retrieve all files
    # save to data_lib
    # create records for each file
  def self.download

  end

    # Read the file data and build the record
  def parsed
    spec
    FixedWidth.parse(File.new(path), :poa_file)
  end


  def populate_file_header(p)
    header = p[:header].first
    header[:poa_type_id] = PoaType.find_by_code(header[:poa_type]).try(:id)
    po_file = PoFile.find_by_file_name(p[:file_name])
    update_from_hash header, :excludes => [:file_name]
    logger.warn "PO File could not be found with name: '#{p[:file_name]}'" if po_file.nil?
  end

  def import
    p = parsed

    populate_file_header(p)
    PoaOrderHeader.populate(p, self)
    PoaVendorRecord.populate(p, self)
    PoaShipToName.populate(p, self)
    PoaAddressLine.populate(p, self)
    PoaCityStateZip.populate(p, self)
    PoaLineItem.populate(p, self)
    PoaAdditionalDetail.populate(p, self)
    PoaLineItemTitleRecord.populate(p, self)
    PoaLineItemPubRecord.populate(p, self)
    PoaItemNumberPriceRecord.populate(p, self)
    PoaOrderControlTotal.populate(p, self)
    PoaFileControlTotal.populate(p, self)

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


  def spec
    FixedWidth.define :poa_file do |d|
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


      PoaOrderHeader.spec(d)
      PoaVendorRecord.spec(d)
      PoaShipToName.spec(d)
      PoaAddressLine.spec(d)
      PoaCityStateZip.spec(d)
      PoaLineItem.spec(d)
      PoaAdditionalDetail.spec(d)
      PoaLineItemTitleRecord.spec(d)
      PoaLineItemPubRecord.spec(d)
      PoaItemNumberPriceRecord.spec(d)
      PoaOrderControlTotal.spec(d)
      PoaFileControlTotal.spec(d)
    end
  end

end