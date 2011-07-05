class Admin::Fulfillment::PoaFilesController < Admin::ResourceController

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

    @pending_files = []
    respond_with @poa_files
  end

  # Download files from CDF
  def download

  end

  # Import files
  def import

  end


end