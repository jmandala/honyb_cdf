class Cdf::ProductBuilder

  IN_STOCK = ["978-0-3732-0000-9", "978-0-3732-0001-6", "978-03732-0002-3", "978-03732-0008-5"]
  
  def self.next_in_stock!
    sku = next_sku(IN_STOCK)
    p = create!(:name => 'In-stock Book', :sku => sku)
    p
  end
  
  def self.next_sku(skus)
    skus.each do |sku|
      return sku if Variant.find_by_sku(sku).nil?
    end
    raise Cdf::IllegalStateError, 'All skus are used! #{skus.to_yaml}' 
  end
  
  private
  
  def self.create!(options = {})
    product = Product.new
    product.available_on = 1.year.ago
    product.shipping_category = shipping_category
    product.tax_category = tax_category
    product.price = 19.99
    product.cost_price = 17.00
    
    options.each_key {|k| product.send("#{k}=", options[k])}
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
