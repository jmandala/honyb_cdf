class Cdf::ProductBuilder

  attr_reader :sku, :index


  def initialize
    @sku = {
        :in_stock => ["978-0-3732-0000-9", "978-0-3732-0001-6", "978-0-3732-0002-3", "978-0-3732-0008-5"],
        :out_of_stock_backorder_cancel => ["9780679854388"],
        :out_of_stock_backorder_nv_cancel => ['9780815605430'],
        :out_of_stock_backorder_ship => ['9780679437222 '],
        :out_of_stock_backorder_nv_ship => ['9781861052346'],
        :out_of_print => ['9780028609249'],
        :split_ship => ['9780394848389'],
        :slash_to_zero_ship => ['9780679864349'],
        :slash_by_1 => ['9780394848365'],
        :not_yet_received => ['9782914563383', '9781845843045'],
        :invalid_ean => ['9781111111119'],
        :valid_not_stocked => ['9781111111113'],        
        :multiple_boxes => ['9780735625723', '9780735623613']
    }
    @index = {}
  end

  def next_product!(sku_type=nil)
    sku_type ||= :in_stock
    name = sku_type.to_s.humanize
    product = self.class.create!(:name => name, :sku => next_sku(sku_type))
    product.on_hand = 1000
    product.save!
    product
  end

  def next_sku(sku_type)
    @index[sku_type] ||= -1
    index = @index[sku_type]
    skus = @sku[sku_type]

    next_index = index + 1

    # if at the end of the list, start over
    if next_index == skus.length
      next_index = 0
    end
    @index[sku_type] = next_index
    skus[next_index]
  end

  private

  def self.create!(options = {})
    sku = options[:sku]
    variant = Variant.find_by_sku sku
    if variant
      product = variant.product

    else
      product = Product.new
    end

    product.available_on = 1.year.ago
    product.shipping_category = shipping_category
    product.tax_category = tax_category
    product.price = 19.99
    product.cost_price = 17.00

    options.each_key { |k| product.send("#{k}=", options[k]) }
    product.save!
    product
  end

  def self.shipping_category
    ShippingCategory.first
  end

  def self.tax_category
    TaxCategory.first
  end
end
