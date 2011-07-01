class Manager

  def generate_po
    po_data
  end


  def po_file_name
    "HB-PO-#{Time.now.strftime('%y%m%d%M')}.fbo"
  end


  def po_data
    orders = find_eligible_orders
    count = init_counters

    po_data = po00.cdf_record + "\n"

    orders.each do |order|
      po = order.as_cdf(count[:total_records])
      po_data << po.to_s
      update_counters(count, order, po)
    end

    po_data << po90(count).cdf_record

  end

  private

  def po00
    Records::Po::Po00.new(po_file_name)
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

  def find_eligible_orders
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