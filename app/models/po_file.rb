require 'net/ftp'

class PoFile < ActiveRecord::Base

  #noinspection RailsParamDefResolve
  has_many :orders, :autosave => true, :dependent => :nullify, :order => 'completed_at asc'

  #noinspection RailsParamDefResolve
  has_many :poa_files, :dependent => :destroy, :order => 'created_at asc'

  #noinspection RubyResolve
  attr_reader :data

  after_create :init_file_name
  before_destroy :delete_file


  def load_file
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)

    @data = ''
    File.open(path, 'r') do |file|
      while line = file.gets
        @data << line
      end
    end
    @data
  end

  def load_data
    # initialize the file name
    save!

    count = init_counters
    @data = po00.cdf_record + Records::Base::LINE_TERMINATOR

    Order.needs_po.limit(25).each do |order|
      self.orders << order
      po = order.as_cdf(count[:total_records])
      @data << po.to_s
      update_counters(count, order, po)
    end

    @data << po90(count).cdf_record

    save!
  end


  # Generates a new PoFile for every order that is ready for
  # shipment
  def self.generate
    po_file = PoFile.new
    po_file.save_data!
    po_file
  end

  def save_data!
    load_data
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write @data }
    save!
  end

  def delete_file
    if File.exists? path
      FileUtils.rm path
    end

  end

  def init_file_name
    self.file_name = prefix + created_at.strftime("%y%m%d%H%M%S") + ext
    save!
  end


  def prefix
    ''
  end

  def ext
    '.fbo'
  end

  def po00
    Records::Po::Po00.new(file_name)
  end

  def po90(count)
    Records::Po::Po90.new(count[:total_records], :name=>'Po90', :count => count)
  end


  def update_counters(count, order, po)
    count[:total_records] += po.count[:total]
    count[:total_purchase_orders] += 1
    count[:total_line_items] += order.line_items.count
    count[:total_units] += order.total_quantity

    for i in 0..8 do
      count[i.to_s] = po.count[i.to_s]
    end
  end


  def init_counters
    count = {
        :total_records => 2, # one for the header and one for the first order
        :total_purchase_orders => 0,
        :total_line_items => 0,
        :total_units => 0
    }

    for i in 0..8 do
      count[i.to_s] = 0
    end
    count
  end

  def path
    "#{CdfConfig::data_lib_out_root(created_at.strftime("%Y"))}/#{file_name}"
  end

  def put
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)

    logger.info "put file #{file_name} to #{Spree::Config.get(:cdf_ftp_server)}"
    begin
      Net::FTP.open(Spree::Config.get(:cdf_ftp_server)) do |ftp|
        ftp.login Spree::Config.get(:cdf_ftp_user), Spree::Config.get(:cdf_ftp_password)
        ftp.chdir 'incoming'
        ftp.put File.new(path)
      end
    rescue StandardError => e
      logger.error e
    end

  end

end