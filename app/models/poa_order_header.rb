# Purchase Order Header Record
class Poa_Order_Header < ActiveRecord::Base
  include Updateable

  belongs_to :poa_file
  belongs_to :po_file

end