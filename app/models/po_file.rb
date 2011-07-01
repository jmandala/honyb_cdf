class PoFile < ActiveRecord::Base
  has_many :orders, :autosave => true, :dependent => :nullify

  attr_reader :data

  before_create :init_file_name

  def save_data!
    load_data
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write @data }
    save!
  end

  def path
    "#{CdfConfig::po_path}/#{file_name}"
  end

  def load_file
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

    @data = po00.cdf_record + "\n"

    Order.needs_po.limit(10).each do |order|
      orders << order
      po = order.as_cdf(count[:total_records])
      @data << po.to_s
      update_counters(count, order, po)
    end

    @data << po90(count).cdf_record

    save!
  end


  def self.generate
    po_file = PoFile.new
    po_file.save_data!
    po_file
  end

  private

  def init_file_name
    self.file_name = prefix + sprintf("%011d", PoFile.count+1) + ext
  end


  def prefix
    "honyb-"
  end

  def ext
    ".fbo"
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
        :total_records => 1,
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