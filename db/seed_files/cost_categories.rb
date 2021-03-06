puts "\n  Loading cost_categories.csv..."
#CostCategory.delete_all
CSV.foreach("db/seed_files/cost_categories.csv", :headers=>true) do |row|
  c               = CostCategory.find_or_initialize_by_external_id(row["id"])
  p               = CostCategory.find_by_external_id(row["parent_id"])
  c.parent_id     = p.id unless p.nil?
  c.description   = row["description"]
  c.short_display = row["short_display"]
  puts "error on #{row}" unless c.save!
  print "."
end
