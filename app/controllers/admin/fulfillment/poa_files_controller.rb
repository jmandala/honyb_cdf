class Admin::Fulfillment::PoaFilesController < Admin::ResourceController

  def show
    begin
      @poa_file
    rescue Exception => e
      flash[:error] = e.message
    end
  end

  def index
    params[:search] ||= {}
    @search = PoaFile.metasearch(params[:search], :distinct => true)

    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end

    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    @poa_files = PoaFile.metasearch(params[:search]).group('poa_files.file_name').paginate(
        :per_page => Spree::Config[:poa_files_per_page],
        :page => params[:page])

    respond_with @poa_files
  end

    # Import files
  def import
    begin
    @object.import
      flash[:notice] = "Imported #{@object.file_name}."
    rescue Exception => e
      flash[:error] = "Failed to import #{@object.file_name}. #{e.message}"
    end

    respond_with(@object) do |format|
      format.html { redirect_to admin_fulfillment_poa_file_path }
      format.js { render :layout => false }
    end

  end


  def location_after_save
    admin_fulfillment_poa_files_path
  end


end