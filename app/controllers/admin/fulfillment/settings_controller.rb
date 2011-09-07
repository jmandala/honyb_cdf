class Admin::Fulfillment::SettingsController < Admin::BaseController

  def update
    begin
      Cdf::Config.set(params[:preferences]) if Cdf::Config.instance
    rescue => e
      logger.error e.message
      raise e
    end

    respond_to do |format|
      format.html {
        redirect_to admin_fulfillment_settings_path
      }
    end
  end

end
