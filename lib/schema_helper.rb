module SchemaHelper

  def safe_drop_table(table_name)
    begin
      drop_table table_name
    rescue Exception => e
      Rails.logger.warn e.message
    end

  end
  # To change this template use File | Settings | File Templates.
end