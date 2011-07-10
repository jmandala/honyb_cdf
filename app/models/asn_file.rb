class AsnFile < ActiveRecord::Base
  include Updateable


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
      d.template :asn_defaults do |t|
        t.record_code 2
        t.client_order_id 22
      end

      d.header(:align => :left) do |h|
        h.trap { |line| line[0, 2] == 'CR' }
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