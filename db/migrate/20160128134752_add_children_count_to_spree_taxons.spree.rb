# This migration comes from spree (originally 20160128122033)
class AddChildrenCountToSpreeTaxons < ActiveRecord::Migration
  def change
    unless column_exists?(:spree_taxons, :children_count)
      add_column :spree_taxons, :children_count, :integer
    end
  end
end
