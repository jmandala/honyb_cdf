class AsnFile < ActiveRecord::Base
  include Updateable

  has_many :orders, :through => :asn_shipments
  has_many :asn_shipments, :dependent => :destroy
  has_many :asn_shipment_details, :dependent => :destroy

    # connect to remote server
    # retrieve all files
    # save to data_lib
    # create records for each file
  def self.download

  end

    # Read the file data and build the record
  def parsed
    spec
    FixedWidth.parse(File.new(path), :asn_file)
  end


  def populate_file_header(p)
    update_from_hash p[:header].first
  end

  def import
    p = parsed

    populate_file_header(p)
    AsnShipment.populate(p, self)
    AsnShipmentDetail.populate(p, self)

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
    FixedWidth.define :asn_file do |d|
      d.template :asn_defaults do |t|
        t.record_code 2
        t.client_order_id 22
      end

      d.header(:align => :left) do |h|
        h.trap { |line| line[0, 2] == 'CR' }
        h.record_code 2
        h.company_account_id_number 10
        h.total_order_count 8
        h.file_version_number 10
        h.spacer 170
      end

      AsnShipment.spec(d)
      AsnShipmentDetail.spec(d)
    end
  end

end