class PoaFile < ActiveRecord::Base

  def self.pending
    [PoaFile.new({:file_name => 'sample.txt'})]
  end
end