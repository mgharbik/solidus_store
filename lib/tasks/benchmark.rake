require 'benchmark'

namespace :benchmark do

  # 4 levels, 30 nodes in each, total 27_931 nodes
  LEVELS = 4
  TAXONS_IN_LEVEL = 30


  desc 'Create taxons'
  task create_taxons: :environment do
    Benchmark.bm do |bm|
      bm.report('Generating the tree') do
        taxonomy = Spree::Taxonomy.create!(name: "benchmark")
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
  ######################## AWESOME NESTED TREE ########################
  #                              user     system      total        real
  # Generating the tree   341.430000  12.840000 354.270000 (765.117659) 12,75196098333333 min

  ######################## Adjacency List #############################
  #                              user     system      total        real
  # Generating the tree   691.820000  10.810000 702.630000 (900.876022) 15.01460036666667 min


  desc 'Display all taxons'
  task display_tree: :environment do
    Benchmark.bm do |bm|
      bm.report('Displaying tree') do
        taxonomy = Spree::Taxonomy.find_by(name: "benchmark")
        parent = taxonomy.root
        self.display_all_children(parent)
      end
    end
  end

  def self.display_all_children(parent)
    children = parent.children
    if children.any?
      children.each do |child|
        self.display_all_children(child)
      end
    else
      parent.name
    end
  end
  ######################## AWESOME NESTED TREE ########################
  #                              user     system      total        real
  # Displaying tree         15.830000   0.620000  16.450000 ( 17.845013)

  ######################## Adjacency List #############################
  #                              user     system      total        real
  # Displaying tree         39.620000   0.830000  40.450000 ( 42.714692)


  desc 'Insert a new taxon'
  task insert_taxon: :environment do
    Benchmark.bm do |bm|
      bm.report('Inserting taxon') do
        taxonomy = Spree::Taxonomy.find_by(name: "benchmark")
        parent = taxonomy.root

        taxon = Spree::Taxon.new(name: "New node", parent_id: parent.id, child_index: 0)
        taxon.taxonomy_id = taxonomy.id
        taxon.save!
      end
    end
  end
  ######################## AWESOME NESTED TREE ########################
  #                              user     system      total        real
  # Inserting taxon         0.070000   0.000000   0.070000 (  0.118796)

  ######################## Adjacency List #############################
  #                              user     system      total        real
  # Inserting taxon         0.090000   0.010000   0.100000 (  0.109642)


  desc 'Move a taxon'
  task move_taxon: :environment do
    Benchmark.bm do |bm|
      bm.report('Moving a taxon') do
        taxonomy = Spree::Taxonomy.find_by(name: "benchmark")
        parent = taxonomy.root.children.first
        node = taxonomy.root.descendants.last

        node.update_attributes!(parent_id: parent.id, child_index: 0)
      end
    end
  end
  ################### AWESOME NESTED TREE ####################
  #                      user     system      total        real
  # Moving a taxon  0.080000   0.010000   0.090000 (  1.653846)

  ################### Adjacency List #########################
  #                      user     system      total        real
  # Moving a taxon  0.100000   0.010000   0.110000 (  0.203947)


  desc 'Remove a taxon'
  task remove_taxon: :environment do
    Benchmark.bm do |bm|
      bm.report('Removing a taxon') do
        taxonomy = Spree::Taxonomy.find_by(name: "benchmark")
        node = taxonomy.root.children.first
        node.destroy!
      end
    end
  end
  ################### AWESOME NESTED TREE ####################
  #                      user     system      total        real
  # Removing a taxon  1.020000   0.060000   1.080000 (  3.554831)

  ################### Adjacency List #########################
  #                      user     system      total        real
  # Removing a taxon  0.080000   0.010000   0.090000 (  0.101363)
end