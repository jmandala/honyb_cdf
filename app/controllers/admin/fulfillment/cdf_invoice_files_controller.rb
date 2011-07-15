class Admin::Fulfillment::CdfInvoiceFilesController < Admin::Fulfillment::ImportController

  # Adds any files that are in the archive/in directory
  # which are not yet added
  # POST
  def load
    count = 0

    model_class.files.each do |f|
      file_name = File.basename(f)

      next if model_class.find_by_file_name(file_name)

      model_class.create(:file_name => file_name)
      count += 1
    end

    flash[:notice] = "Loaded #{count} files."

    respond_to do |format|
      format.html { redirect_to admin_fulfillment_cdf_invoice_files_path }
      format.js { render :layout => false }
    end
  end

end