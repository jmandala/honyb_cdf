class Manager

  def generate_po
    # find orders
    orders = find_eligible_orders

      # for each order, add to string
    po_data = as_po

    # write string to file
    # return file

    po_data
  end

  def find_eligible_orders
    Order.complete.limit(1)
  end

  def as_po
    orders = find_eligible_orders
    count = 1
    po00 = Records::Po::Po00.new
    po_data = po00.cdf_record + "\n"
    orders.each do |order|
      po = order.as_cdf(count)
      po_data << po.to_s
      count += po.count[:total]
    end

    po_data << "#{count}FOOTER"

  end

end