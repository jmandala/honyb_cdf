class PoaFileControlTotal < ActiveRecord::Base
  include Updateable

  belongs_to :poa_file

  def self.spec(d)
    d.poa_file_control_total do |l|
      l.trap { |line| line[0, 2] == '91' }
      l.template :poa_defaults
      l.total_line_items_in_file 13
      l.total_pos_acknowledged 5
      l.total_units_acknowledged 10
      l.record_count_01 5
      l.record_count_02 5
      l.record_count_03 5
      l.record_count_04 5
      l.record_count_05 5
      l.record_count_06 5
      l.spacer 10
    end
  end

  def self.populate(p, poa_file)
    p[:poa_file_control_total].each do |data|
      data[:poa_file_id] = poa_file.id
      object = self.find_or_create_by_poa_file_id(data[:poa_file_id])
      object.update_from_hash(data)
    end
  end


end
