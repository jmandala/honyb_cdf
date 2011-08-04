class CdfConfig

  def self.data_lib_path
    File.join Cdf::Engine::config.root, 'data_lib'
  end

  def self.archive_path
    File.join self.data_lib_path, 'archive'
  end

  def self.translation_files
    File.join self.archive_path, 'translation_files'
  end

  def self.data_lib_out_root(year='')
    if year.empty?
      return File.join(self.data_lib_path, 'out')
    end
    
    File.join self.data_lib_path, 'out', year
  end

  def self.data_lib_in_root(year='')
    if year.empty?
      return File.join(self.data_lib_path, 'in')
    end

    File.join self.data_lib_path, 'in', year
  end

  def self.current_data_lib_out
    self.data_lib_out_root self.this_year
  end

  def self.current_data_lib_in
    self.data_lib_in_root self.this_year
  end

  def self.po_status_file
    File.join(self.translation_files, 'POStatus Vers 03.txt')
  end

  def self.poa_status_file
    File.join(self.translation_files, 'POAStatus Vers 03.txt')
  end

  def self.dc_codes_file
    File.join(self.translation_files, 'DCCodes CDFL.txt')
  end

  def self.states_file
    File.join(self.translation_files, 'State.txt')
  end

  def self.ensure_path(path)
    FileUtils.mkdir_p path
  end

  private

  def self.this_year
    Time.now.strftime "%Y"
  end
end