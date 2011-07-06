require 'fixed_width'

class PoaFile < ActiveRecord::Base

  attr_reader :data


  # connect to remote server
  # retrieve all files
  # save to data_lib
  # create records for each file
  def self.download

  end

  # Read the file data and build the record
  def parsed
    spec
    @parsed = FixedWidth.parse(File.new(path), :poa_file)
  end


  def populate
    #todo! parse & load
  end


  def path
    "#{CdfConfig::data_lib_in_root(created_at.strftime("%Y"))}/#{file_name}"
  end

  def load_file
    raise ArgumentError, "File not found: #{path}"  unless File.exists?(path)

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
        h.trap { |line| line[0,2] == '02' }
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

      d.poa11 do |l|
        l.trap { |line| line[0,2] == '11' }
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

end