class AddIndexToPkpWaybillBaseLocals < ActiveRecord::Migration
  def change
    add_index :pkp_waybill_base_locals, :query_result_id
  end
end
