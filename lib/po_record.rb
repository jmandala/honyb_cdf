class PoRecord < CdfRecord

  def initialize(order, start_sequence)
    @order = order
    @sequence = start_sequence
    @data = []
  end

  def append(clazz)
    record = clazz.send(:new, @order, @sequence)
    @sequence += 1
    record.cdf_record
  end


  def to_s
    cdf = StringIO.new
    cdf << append(Po10) + "\n"
    cdf << append(Po20) + "\n"
    cdf << append(Po21) + "\n"
    cdf << append(Po24) + "\n"
    cdf << append(Po25) + "\n"
    cdf << append(Po26) + "\n"
    cdf << append(Po27) + "\n"
    cdf.string
  end


end