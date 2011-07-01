class CdfConfig

  def self.data_lib_path
    "#{Cdf::Engine::config.root}/data_lib"
  end

  def self.po_path_root
    "#{self.data_lib_path}/out"
  end

  def self.po_path
    "#{self.po_path_root}/#{self.this_year}"
  end

  private

  def self.this_year
    Time.now.strftime "%Y"
  end
end