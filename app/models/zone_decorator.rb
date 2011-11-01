Zone.class_eval do
  
  def includes_zoneable?(zoneable)
    members.any? do |member|
      member.zoneable == zoneable
    end
  end
  
  def self.all_us
    where(:name => 'ALL US').first
  end
  
  def self.intl
    where(:name => 'International').first
  end
end
