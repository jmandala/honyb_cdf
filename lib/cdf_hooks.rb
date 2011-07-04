class CdfHooks < Spree::ThemeSupport::HookListener

  insert_after :admin_tabs do
    "<%= tab :fulfillment_dashboard, :po_files, :poa_files %>"
  end

  insert_after :admin_order_tabs do
    %(
    <li<%== ' class="active"' if current == "Fulfillment" %>>
       <%= link_to t("fulfillment"), fulfillment_admin_order_path(@order) %>
    </li>
    )
  end
end