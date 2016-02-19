# This migration comes from solidus_slider (originally 20160102194238)
class AddAttachmentToSliders < ActiveRecord::Migration
  def change
    add_attachment :spree_slides, :attachment
  end
end
