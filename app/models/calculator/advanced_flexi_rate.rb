#
# This shipping method is just like [Calculator::]FlexiRate] with a few notable exceptions
# * Is aware of "child" shipments for cases where the shipment 
#   was generated by the application for fulfillment reasons, and not as the result
#   of the customer's request. In these cases, the per-shipment fee *may* be waived
# * Calculates it's price based on the number of inventory_units assigned 
class Calculator::AdvancedFlexiRate < Calculator

  preference :first_item, :decimal, :default => 0
  preference :additional_item, :decimal, :default => 0
  preference :max_items, :decimal, :default => 0

  # the first item fee when this is a child shipment
  preference :child_shipment_first_item, :decimal, :default => 0

  def self.description
    I18n.t("advanced_flexible_rate")
  end

  def self.available?(object)
    true
  end

  # Returns the shipping cost based on the number of line_items
  # associated with *object*
  def compute_for_line_items(object)
    sum = 0
    max = self.preferred_max_items
    items_count = object.line_items.map(&:quantity).sum
    items_count.times do |i|
      # check max value to avoid divide by 0 errors
      if (max == 0 && i == 0) || (max > 0) && (i % max == 0)
        sum += self.preferred_first_item
      else
        sum += self.preferred_additional_item
      end
    end
    sum
  end

  def compute_for_inventory_units(object)
    sum = 0
    max = self.preferred_max_items
    object.inventory_units.count.times do |i|
      if (max == 0 && i == 0) || (max > 0) && (i % max == 0)                
        sum += is_a_child?(object) ? self.preferred_first_child_item : self.preferred_first_item
      else
        sum += self.preferred_additional_item
      end
    end
    sum
  end

  # Returns the shipping cost per inventory_units if there are some
  # Otherwise returns the shipping cost per line_items
  def compute(object)
    return compute_for_inventory_units(object) unless object.inventory_units.empty?
    compute_for_line_items(object)
  end
  
  def is_a_child?(object)
    object.respond_to?(:child?) && object.child?
  end


end