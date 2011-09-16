class AsnFile < ActiveRecord::Base
  include Importable
  include Records


  has_many :orders, :through => :asn_shipments
  has_many :asn_shipments, :dependent => :destroy
  has_many :asn_shipment_details, :dependent => :destroy

  has_many :versions, :class_name => AsnFile.name, :foreign_key => 'parent_id', :autosave => true
  belongs_to :parent, :class_name => AsnFile.name

  collaborator AsnShipment
  collaborator AsnShipmentDetail

  define_ext 'PBS'
  define_length 200

  import_format do |d|
    d.template :asn_defaults do |t|
      t.record_code 2
      t.client_order_id 22
    end

    d.header(:align => :left) do |h|
      h.trap { |line| line[0, 2] == 'CR' }
      h.record_code 2
      h.company_account_id_number 10
      h.total_order_count 8
      h.file_version_number 10
      h.spacer 170
    end
  end
end