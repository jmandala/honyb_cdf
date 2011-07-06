class CdfConfig

  def self.data_lib_path
    "#{Cdf::Engine::config.root}/data_lib"
  end

  def self.data_lib_out_root(year='')
    if year.empty?
      return "#{self.data_lib_path}/out"
    end
    
    "#{self.data_lib_path}/out/#{year}"
  end

  def self.data_lib_in_root(year='')
    if year.empty?
      return "#{self.data_lib_path}/in"
    end

    "#{self.data_lib_path}/in/#{year}"
  end

  def self.current_data_lib_out
    self.data_lib_out_root self.this_year
  end

  def self.current_data_lib_in
    self.data_lib_in_root self.this_year
  end

  private

  def self.this_year
    Time.now.strftime "%Y"
  end
end