module DataViewHelper
   def data_pair(field_name, opts={})
      
      opts[:class] ||= field_name.to_s
      opts[:label] ||= t(field_name.to_s)
      
      if block_given?
        value = yield field_name
      else 
        value = ''
      end
      
      """
      <div class='data_pair #{opts[:class]}'><label>#{opts[:label]}</label>#{value}</div>
      """
    end
end