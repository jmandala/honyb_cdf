class String
  def ljust_trim(length, padstr = ' ')
    if self.length <= length
      return self.ljust length, padstr
    end

    Rails.logger.warn "String trimmed. Orig '#{self}'. Length: '#{length}'"
    self[0, length-1]

  end
  
  def no_dashes
    self.gsub(/\-/, '')
  end
end