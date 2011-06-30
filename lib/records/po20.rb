module Records

# Optional
# Fixed Special Handling Instructions
  class Po20 < PoBase

    def cdf_record
      cdf = super
      cdf << special_handling_codes
      cdf << reserved(21)
    end

    def special_handling_codes
      reserved(30)
    end

  end
end