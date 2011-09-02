class CdfHooks < Spree::ThemeSupport::HookListener

  insert_after :admin_tabs do
    "<%= tab :fulfillment_dashboard, :po_files, :poa_files, :asn_files, :cdf_invoice_files %>"
  end

  insert_after :admin_order_tabs do
    %(
    <li<%== ' class="active"' if current == "Fulfillment" %>>
       <%= link_to t("fulfillment"), fulfillment_admin_order_path(@order) %>
    </li>
    )
  end
  
  replace :order_details_line_item_row, 'admin/shared/order_details_line_item_row'
  insert_after :admin_order_show_buttons, 'admin/shared/order_details_extra_buttons'

  insert_after :admin_configurations_menu do
    %(
    <tr>
        <td><%= link_to t("fulfillment"), admin_fulfillment_settings_path %></td>
        <td><%= t("fulfillment_settings_description") %></td>
      </tr>
    )
  end

  insert_after :admin_configurations_sidebar_menu do
    %(
      <li<%== ' class="active"' if controller.controller_name == 'settings' %>><%= link_to t("fulfillment"), admin_fulfillment_settings_path %></li>
    )
  end


  insert_after :admin_inside_head do
    %(<%= stylesheet_link_tag 'admin/cdf', :cache => 'admin/cdf' %>)
  end



end