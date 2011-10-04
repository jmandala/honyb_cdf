require 'net/ftp'

class PoFile < ActiveRecord::Base

  #noinspection RailsParamDefResolve
  has_many :orders, :autosave => true, :dependent => :nullify, :order => 'completed_at asc'

  #noinspection RailsParamDefResolve
  has_many :poa_files, :dependent => :destroy, :order => 'created_at asc'

  after_create :init_file_name

  before_destroy :delete_file

  attr_reader :count

  def read
    raise ArgumentError, "File not found: #{path}" unless has_file?

    File.read path
  end

  def has_file?
    self.persisted? ? File.exists?(path) : false
  end

  def initialize(attributes={})
    @count = init_counters
    super
  end


  # Generates a new PoFile for every order that is ready for
  # shipment
  def self.generate
    po_file = PoFile.new
    po_file.save!

    data = po_file.po00.cdf_record + Records::Base::LINE_TERMINATOR

    Order.needs_po.limit(25).each do |order|
      po_file.orders << order
      po = order.as_cdf(po_file.count[:total_records])
      data << po.to_s
      po_file.update_counters(order, po)
    end

    data << po_file.po90.cdf_record

    FileUtils.mkdir_p(File.dirname(po_file.path))
    File.open(po_file.path, 'w') { |f| f.write data }

    po_file.save!
    po_file
  end

  def self.prefix
    ''
  end

  def self.ext
    '.fbo'
  end

  def delete_file
    if self.persisted? && File.exists?(path)
      FileUtils.rm path
      return true
    end

    false
  end

  def init_file_name
    self.file_name = self.class.prefix + self.created_at.strftime("%y%m%d%H%M%S") + self.class.ext
    save!
  end


  def po00
    Records::Po::Po00.new(file_name)
  end

  def po90
    Records::Po::Po90.new(@count[:total_records], :name=>'Po90', :count => @count)
  end


  def update_counters(order, po)
    @count[:total_records] += po.count[:total]
    @count[:total_purchase_orders] += 1
    @count[:total_line_items] += order.line_items.count
    @count[:total_units] += order.total_quantity

    (0..8).each { |i| @count[i.to_s] = po.count[i.to_s] }

  end

  def path
    raise Cdf::IllegalStateError, "Can't get path until PoFile has been saved" unless persisted?

    "#{CdfConfig::data_lib_out_root(self.created_at.strftime("%Y"))}/#{file_name}"
  end

  def put
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)

    return self.submitted_at if self.submitted?

    client = CdfFtpClient.new

    puts client.to_yaml

    list = []
    client.connect do |ftp|
      ftp.chdir 'incoming'
      ftp.put File.new(path)
      list = ftp.list
    end
    
    puts list.to_yaml

    self.submitted_at = Time.now
    self.save!
    self.submitted_at
  end
  
  # Returns true if already submitted
  def submitted?
    !self.submitted_at.nil?
  end
  
  # Returns PoFiles that have not been submitted
  def self.not_submitted
    where(:submitted_at => nil)
  end

  private
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


end