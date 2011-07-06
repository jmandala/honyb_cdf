require 'fixed_width'

class PoaFile < ActiveRecord::Base
  include Updateable

  has_many :poa_order_headers, :dependent => :destroy, :autosave => true

  belongs_to :poa_type

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


  def populate
    #todo! parse & load
    p = parsed
    populate_header(p)
    populate_poa_order_header(p)

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
      d.template :boundary do |t|
        t.record_code 2
        t.sequence_number 5
      end

      d.header(:align => :left) do |h|
        h.trap { |line| line[0, 2] == '02' }
        h.template :boundary
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

      d.poa_order_header do |l|
        l.trap { |line| line[0, 2] == '11' }
        l.template :boundary
        l.toc 13
        l.po_number 22
        l.icg_ship_to_account_number 7
        l.icg_san 7
        l.po_status 1
        l.po_acknowledgement_date 6
        l.po_date 6
        l.po_cancellation_date 6
        l.spacer 5
      end
    end
  end


  private

  def populate_header(p)
    header = p[:header].first
    header[:poa_type_id] = PoaType.find_by_code(header[:poa_type]).try(:id)
    update_from_hash header, :excludes => [:file_name]
  end

  def populate_poa_order_header(p)
    p[:poa_order_header].each do |data|
      order = Order.find_by_number(data[:po_number])

      if order.nil?
        raise ActiveRecord::RecordNotFound.new("No Order found with number: #{data[:po_number]}")
      end

      if order.po_file.nil?
        raise ActiveRecord::RecordNotFound.new("No PO File found for order number: #{data[:po_number]}")
      end

      po_file = order.po_file

      poa_order_header = PoaOrderHeader.find_or_create_by_po_file_id_and_poa_file_id(po_file.id, id)

      data[:po_status_id] = PoStatus.find_by_code(data[:po_status]).try(:id)

      poa_order_header.update_from_hash(data)
    end
  end

end