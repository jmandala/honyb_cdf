module Records

  module Po
# Optional
# Fixed Special Handling Instructions
    class Po20 < PoBase

      def cdf_record
        return nil unless has_special_handling_codes

        cdf = super
        cdf << special_handling_codes
        cdf << reserved(21)

        PoBase.ensure_length cdf
      end

      def has_special_handling_codes
        special_handling_codes.strip.length > 0
      end

      def special_handling_codes
        reserved(30)
      end

    end
  end
end