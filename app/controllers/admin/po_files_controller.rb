class Admin::PoFilesController < Admin::ResourceController


  def create
    @object = PoFile.generate

    flash[:notice] = flash_message_for(@object, :successfully_created)
    respond_with(@object) do |format|
      format.html { redirect_to location_after_save }
      format.js { render :layout => false }
    end
  end

  def show
    begin
      @po_file.load_file
      @data = @po_file.data
    rescue Exception => e
      flash[:error] = "#{e.message}"
    end
  end

  def index
    
  end

end