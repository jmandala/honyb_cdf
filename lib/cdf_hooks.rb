class CdfHooks < Spree::ThemeSupport::HookListener

  insert_after :admin_tabs do
     "<%= tab :fulfillment, :route => :admin_fulfillment %>"
  end

end