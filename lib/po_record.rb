require 'csv'

class PoRecord < CdfRecord

  def initialize(order, start_sequence)
    @order = order
    @sequence = start_sequence
    @data = []
    @count = 0
  end

  def append(clazz, args = {})
    args[:name] = clazz.name
    record = clazz.send(:new, @order, @sequence, args)
    @sequence += 1
    @count += 1

    record.cdf_record + "\n"
  end


  def to_s
    cdf = StringIO.new
    cdf << append(Po10)
    cdf << append(Po20)
    cdf << append(Po21)
    cdf << append(Po24)
    cdf << append(Po25)
    cdf << append(Po26)
    cdf << append(Po27)
    cdf << append(Po27, :address_line => :address2)
    cdf << append(Po29)
    cdf << append(Po30)
    cdf << append(Po31)
    cdf << append(Po32)
    cdf << append(Po32, :address_line => :address2)
    cdf << append(Po34)
    cdf << append(Po35)
    cdf << append(Po37, :message => marketing_message)

    if @order.gift_message
      cdf << append(Po38, :message => @order.gift_message)
    end

    @order.line_items.each do |line_item|
      cdf << append(Po40, :line_item => line_item)
      cdf << append(Po41, :line_item => line_item)
      if line_item.gift_message
        cdf << append(Po42, :line_item => line_item, :message => line_item.gift_message)
      end
    end

    cdf << append(Po50, :record_count => @count+1)

    cdf.string
  end

  def marketing_message
    "HonyB Is Direct Commerce"
  end

end