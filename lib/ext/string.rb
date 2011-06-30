class String
  def ljust_trim(length, padstr = ' ')
    if self.length <= length
      self.ljust length, padstr
    else
      self[0,length-1]
    end
  end
end