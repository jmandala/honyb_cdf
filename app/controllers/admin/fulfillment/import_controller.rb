class Admin::Fulfillment::ImportController < Admin::ResourceController

  def index
    params[:search] ||= {}
    @search = model_class.metasearch(params[:search], :distinct => true)

    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end

    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    @collection = model_class.metasearch(params[:search]).group("#{object_name}s.file_name").paginate(
        :per_page => Spree::Config["#{object_name}s_per_page"],
        :page => params[:page])

    respond_with @collection
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
      format.html { redirect_to location_after_save }
      format.js { render :layout => false }
    end

  end

  def location_after_save
    polymorphic_url(@object, :action => 'admin_fulfillment')
  end
end