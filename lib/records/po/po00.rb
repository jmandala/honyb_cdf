module Records
  module Po
# Client Header
    class Po00 < Records::Base

      def initialize()
        super(1, {:name => Po00.name})
      end

      def cdf_record
        cdf = super

      end


    end
  end
end