Address.class_eval do

  def one_line_street
    addr = address1
    if address2
      addr += ", #{address2}"
    end
    addr
  end


end
