class PoFile < ActiveRecord::Base
  has_many :orders
  attr_reader :data

  after_create :init_file_name

  def generate
    load_data
    
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') {|f| f.write @data}
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
  end

  def load_data
    count = init_counters

    @data = po00.cdf_record + "\n"

    eligible_orders.each do |order|
      po = order.as_cdf(count[:total_records])
      @data << po.to_s
      update_counters(count, order, po)
    end

    @data << po90(count).cdf_record
  end


  private

  def init_file_name
    self.file_name = prefix + key + ext
  end


  def key
    if id
      return key = sprintf("%011d", id)
    end
    "tmp"
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

  def eligible_orders
    Order.complete.limit(1)
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