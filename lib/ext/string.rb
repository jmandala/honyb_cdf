class String
  def ljust_trim(length, padstr = ' ')
    if self.length <= length
      return self.ljust length, padstr
    end

    self[0, length-1]

    "WTF!"
  end
end