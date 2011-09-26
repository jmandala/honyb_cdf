module DataView
  def data_pair(field_name, opts={})

    opts[:class] ||= field_name
    opts[:label] ||= I18n.t(field_name, :locale => 'en')
    opts[:value_class] ||= 'value'

    if block_given?
      value = yield field_name
    else
      value = ''
    end

    "" "
      <div class='#{opts[:class]}'><label>#{opts[:label]}</label><span class='#{opts[:value_class]}'>#{value}</span></div>
      " ""
  end
end