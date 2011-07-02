class CdfHooks < Spree::ThemeSupport::HookListener

  insert_after :admin_tabs do
    "<%= tab :fulfillment, :po_files, :route => :admin_fulfillment %>"
  end

  insert_after :admin_order_tabs do
    %(
    <li<%== ' class="active"' if current == "Fulfillment" %>>
       <%= link_to t("fulfillment"), fulfillment_admin_order_path(@order) %>
    </li>
    )
  end
end