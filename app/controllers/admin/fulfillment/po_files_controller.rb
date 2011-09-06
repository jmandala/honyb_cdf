class Admin::Fulfillment::PoFilesController < Admin::ResourceController

  def create
    if Order.needs_po.count == 0
      flash[:notice] = 'No Orders need POs'
      return redirect_to location_after_save
    end

    @object = PoFile.generate

    flash[:notice] = flash_message_for(@object, :successfully_created)
    respond_with(@object) do |format|
      format.html { redirect_to location_after_save }
      format.js { render :layout => false }
    end
  end
  
  def submit
    @po_file = PoFile.find_by_id params[:id]
    @po_file.put
    flash[:notice] = "Submitted PO File #{@po_file.file_name}"
    redirect_to :action => :show
  end

  def show
    begin
      @po_file.load_file
      @data = @po_file.data
    rescue Exception => e
      flash[:error] = e.message
    end
  end

  def index
    params[:search] ||= {}
    @search = PoFile.metasearch(params[:search], :distinct => true)

    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end

    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    @po_files = PoFile.metasearch(params[:search]).group('po_files.file_name').paginate(
        :per_page => Cdf::Config[:po_files_per_page],
        :page => params[:page])

    respond_with @po_files
  end


    # Deletes all PoFiles
  def purge
    count = PoFile.count
    Order.update_all('po_file_id = NULL', 'po_file_id IS NOT NULL')
    PoFile.delete_all
    flash[:notice] = "Deleted #{count} PoFiles"

    redirect_to location_after_save
  end

  def location_after_save
    admin_fulfillment_po_files_path
  end


end