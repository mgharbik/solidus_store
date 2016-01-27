# This migration comes from spree (originally 20160104084433)
class AddPositionToSpreeTaxons < ActiveRecord::Migration
  def change
    unless column_exists?(:spree_taxons, :position)
      add_column :spree_taxons, :position, :integer
    end
  end
end
