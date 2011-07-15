class Admin::Fulfillment::CdfInvoiceFilesController < Admin::Fulfillment::ImportController

  # Adds any files that are in the archive/in directory
  # which are not yet added
  # POST
  def load
    count = 0
    Dir.glob(CdfConfig::current_data_lib_in + "/*.bin").each do |f|
      file_name = File.basename(f)

      next if CdfInvoiceFile.find_by_file_name(file_name)

      CdfInvoiceFile.create(:file_name => file_name)
      count += 1
    end

    flash[:notice] = "Loaded #{count} files."

    respond_to do |format|
      format.html { redirect_to admin_fulfillment_cdf_invoice_files_path }
      format.js { render :layout => false }
    end


  end

end