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

    header = p[:header].first
    header[:poa_type_id] = PoaType.find_by_code(header[:poa_type]).try(:id)
    update_from_hash header, :excludes => [:file_name]

    PoaOrderHeader.populate(p)

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

      PoaOrderHeader.spec(d)
      
    end
  end

end