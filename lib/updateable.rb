module Updateable

  # updates the associated object with values in the supplied hash
  # If options include an :exclude key, any supplied hash keys will be skipped
  # Difference from ActiveRecord::Base#update_attributes in that it will silently ignore any new attributes that
  # are not recognized by the model
  def update_from_hash(new_attributes, options = {})
    return unless new_attributes.is_a?(Hash)

    excludes = options[:excludes] || []

    new_attributes.each do |k, v|
      next if excludes.include? k
      update_attribute(k.to_s, v) if has_attribute? k
    end
  end

end