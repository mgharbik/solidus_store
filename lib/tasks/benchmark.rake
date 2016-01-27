require 'benchmark'

namespace :benchmark do

  LEVELS = 4
  TAXONS_IN_LEVEL = 10
  ITERATIONS = 10

  desc 'Create taxons'
  task create_taxons: :environment do
    Benchmark.bmbm do |bm|
      bm.report('Generating the tree') do
        taxonomy = Spree::Taxonomy.create!(name: "taxonomy test")
        parent = taxonomy.root
        level = 1

        (1..TAXONS_IN_LEVEL).each do |index|
          self.build_taxon(taxonomy, parent, level, index)
        end
      end
    end
  end

  def self.build_taxon(taxonomy, parent, level, index)
    taxon = taxonomy.taxons.create!(name: "taxon-#{level}-#{index}", child_index: index, parent_id: parent.id)

    if level + 1 < LEVELS
      (1..TAXONS_IN_LEVEL).each do |index|
        self.build_taxon(taxonomy, taxon, level + 1, index)
      end
    end
  end
  # AWESOME NESTED TREE, 10 levels, 2 nodes in each, total 2046 nodes
  # Rehearsal -------------------------------------------------------
  # Generating the tree  12.400000   0.530000  12.930000 ( 18.950261)
  # --------------------------------------------- total: 12.930000sec
  #
  # user     system      total        real
  # Generating the tree  12.180000   0.480000  12.660000 ( 18.830448)

  # AWESOME NESTED TREE, 4 levels, 10 nodes in each, total 2222 nodes
  # Rehearsal -------------------------------------------------------
  # Generating the tree  13.290000   0.540000  13.830000 ( 19.043550)
  # --------------------------------------------- total: 13.830000sec
  #
  # user     system      total        real
  # Generating the tree  13.050000   0.500000  13.550000 ( 19.592345)


  #
  # CLOSURE TREE, 10 levels, 2 nodes in each, total 2046 nodes
  # Rehearsal -------------------------------------------------------
  # Generating the tree   9.530000   0.410000   9.940000 ( 15.795836)
  # ---------------------------------------------- total: 9.940000sec
  #
  #                           user     system      total        real
  # Generating the tree   9.110000   0.350000   9.460000 ( 12.666454)

  # CLOSURE TREE, 4 levels, 10 nodes in each, total 2222 nodes
  # Rehearsal -------------------------------------------------------
  # Generating the tree   9.690000   0.390000  10.080000 ( 13.550858)
  # --------------------------------------------- total: 10.080000sec
  #
  # user     system      total        real
  # Generating the tree   9.610000   0.380000   9.990000 ( 13.744228)

  desc 'Move taxons'
  task move_taxons: :environment do
    Benchmark.bmbm do |bm|
      bm.report('Moving taxons') do
        taxonomy = Spree::Taxonomy.last
        ITERATIONS.times do |i|
          parent = taxonomy.reload.root.children.first
          taxon = taxonomy.reload.root.children.last
          self.move_taxon(parent, taxon)

          parent = taxonomy.reload.root
          taxon = taxonomy.reload.root.children.first
          self.move_taxon(parent, taxon)

          puts i
        end
      end
    end
  end

  def self.move_taxon(parent, taxon, position=0)
    taxon.parent = parent
    taxon.child_index = position

    taxon.save!

    taxon.reload
    taxon.set_permalink
    taxon.save!

    taxon.descendants.each do |descendant|
      descendant.reload
      descendant.set_permalink
      descendant.save!
    end
  end
  # AWESOME NESTED TREE

  #
  # CLOSURE TREE, 10 levels, 2 nodes in each, 20 operations
  # Rehearsal -------------------------------------------------
  # Moving taxons 108.530000   4.390000 112.920000 (172.196368)
  # -------------------------------------- total: 112.920000sec
  #
  #                     user     system      total        real
  # Moving taxons 103.740000   4.100000 107.840000 (151.867194)

  # CLOSURE TREE, 4 levels, 10 nodes in each, 20 operations
  # Rehearsal -------------------------------------------------
  # Moving taxons 22.310000   0.850000  23.160000 ( 31.205913)
  # --------------------------------------- total: 23.160000sec
  #
  # user     system      total        real
  # Moving taxons 33.150000   1.240000  34.390000 ( 46.282565)

  desc 'Remove taxons'
  task remove_taxons: :environment do
    Benchmark.bmbm do |bm|
      bm.report('Removing taxons') do
        count = Spree::Taxon.count
        Spree::Taxon.take(1000).each do |taxon|
          taxon.destroy!
        end
      end
    end
  end
  # AWESOME NESTED TREE, 10 levels, 2 nodes in each, total 2000 nodes destroyed
  # Rehearsal ---------------------------------------------------
  # Removing taxons   4.880000   0.270000   5.150000 (  8.913004)
  # ------------------------------------------ total: 5.150000sec
  #
  # user     system      total        real
  # Removing taxons   0.000000   0.000000   0.000000 (  0.003072)

  # AWESOME NESTED TREE, 4 levels, 10 nodes in each, total 2000 nodes destroyed
  # Rehearsal ---------------------------------------------------
  # Removing taxons   3.890000   0.220000   4.110000 ( 28.071545)
  # ------------------------------------------ total: 4.110000sec
  #
  # user     system      total        real
  # Removing taxons   3.480000   0.190000   3.670000 (  8.643678)

  #
  #
  # CLOSURE TREE, 10 levels, 2 nodes in each, total 2000 nodes destroyed
  # Rehearsal ---------------------------------------------------
  # Removing taxons   5.240000   0.240000   5.480000 (  5.636259)
  # ------------------------------------------ total: 5.480000sec
  #
  # user     system      total        real
  # Removing taxons   5.390000   0.240000   5.630000 (  5.830917)

  # CLOSURE TREE, 4 levels, 10 nodes in each, total 2000 nodes destroyed
  # Rehearsal ---------------------------------------------------
  # Removing taxons   6.830000   0.310000   7.140000 (  7.178417)
  # ------------------------------------------ total: 7.140000sec
  #
  # user     system      total        real
  # Removing taxons   6.530000   0.290000   6.820000 (  6.829724)
end