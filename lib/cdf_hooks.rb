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

  insert_after :admin_configurations_menu do
    %(
    <tr>
        <td><%= link_to t("fulfillment"), admin_fulfillment_settings_path %></td>
        <td><%= t("fulfillment_settings_description") %></td>
      </tr>
    )
  end
end