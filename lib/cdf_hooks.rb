class CdfHooks < Spree::ThemeSupport::HookListener

  insert_after :admin_tabs do
     "<%= tab :fulfillment, :po_files, :route => :admin_fulfillment %>"
  end

end