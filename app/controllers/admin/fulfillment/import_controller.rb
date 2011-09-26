class Admin::Fulfillment::ImportController < Admin::ResourceController
  
  helper :data_view

  def create
    #begin
      files = model_class.download
      flash[:notice] = "#{files.count} files downloaded."
    #rescue => e
    #  flash[:error] = "Error downloading #{model_class}: #{e.message}, #{e.backtrace}"
    #end
    respond_with(@object) do |format|
      format.html { redirect_to polymorphic_url([:admin, :fulfillment, model_class]) }
      format.js { render :layout => false }
    end
  end

  def index
    @downloadable = model_class.remote_files
    
    params[:search] ||= {}
    @search = model_class.metasearch(params[:search], :distinct => true)

    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end

    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    @collection = model_class.metasearch(params[:search]).order('created_at desc').group("#{object_name}s.file_name").paginate(
        :per_page => Cdf::Config["#{object_name}s_per_page"],
        :page => params[:page])

    respond_with @collection
  end

  # Import files
  def import
    begin
      result = @object.import!
      flash[:notice] = "Imported #{@object.file_name}."

    rescue => e
      flash[:error] = "#{e.message}"


    end
    respond_with(@object) do |format|
      format.html { redirect_to polymorphic_url([:admin, :fulfillment, object_name]) }
      format.js { render :layout => false }
    end

  rescue Exception => e
    flash[:error] = "Failed to import #{@object.file_name}. #{e.message}"
    logger.error e.backtrace
    raise e
  end


end

def location_after_save
  polymorphic_url(@object, :action => 'admin_fulfillment')
end

# Adds any files that are in the archive/in directory
# which are not yet added
# POST
def load_files
  count = 0

  model_class.files.each do |f|
    file_name = File.basename(f)

    next if model_class.find_by_file_name(file_name)

    model_class.create(:file_name => file_name)
    count += 1
  end

  flash[:notice] = "Loaded #{count} files."

  respond_to do |format|
    format.html { redirect_to send("admin_fulfillment_#{object_name}s_path") }
    format.js { render :layout => false }
  end
end
