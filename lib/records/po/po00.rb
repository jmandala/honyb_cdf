module Records
  module Po
# Client Header
    class Po00 < Records::Base

      def initialize(file_name)
        @file_name = file_name
        super(1, {:name => Po00.name})
      end

      def cdf_record
        cdf = super
        cdf << file_source_san
        cdf << reserved(5)
        cdf << file_source_name
        cdf << creation_date
        cdf << file_name
        cdf << format_version
        cdf << ingram_san
        cdf << reserved(5)
        cdf << vendor_flag_name
        cdf << product_description
        
        PoBase.ensure_length cdf
      end

      def file_source_san
        sprintf("%07d", 0)
      end

      def file_source_name
        "HonyB".ljust_trim 13
      end

      def format_version
        "F03"
      end

      def ingram_san
        "1697978"
      end

      def vendor_flag_name
        "I"
      end

      def product_description
        "CDFL"
      end

      def creation_date
        cdf_date(Time.now)
      end
      
       def file_name
        @file_name.ljust_trim 22
      end
    end
  end
end