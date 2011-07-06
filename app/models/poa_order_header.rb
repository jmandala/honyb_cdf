# Purchase Order Header Record
class PoaOrderHeader < ActiveRecord::Base
  include Updateable

  belongs_to :poa_file
  belongs_to :po_file

end