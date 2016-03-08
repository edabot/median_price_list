require 'byebug'
require 'csv'

city_list = [] # city names with state
city_data = [] # city name, rents, median

contents = File.read(ARGV[0])
contents = contents.split(/[\r]+/)

contents.each do |line|
  line = line.split(",")
  city = line[1].gsub(/\w+/, &:capitalize)
  state = line[2].upcase
  city_w_state = "#{city} #{state}"
  if !city_list.include?(city_w_state)
    city_list << city_w_state
    city_data << [city, state, []]
  end
  city_idx = city_list.index(city_w_state)
  city_data[city_idx][2] << line[3].to_i
end

city_data.each_index do |city|
  sorted_rents = city_data[city][2].sort
  middle = sorted_rents.length/2

  if sorted_rents.length.odd?
    city_data[city] << sorted_rents[middle]
  else
    city_data[city] << ((sorted_rents[middle] + sorted_rents[middle - 1]) / 2)
  end
end

city_data.sort!{ |x,y| y[2].size <=> x[2].size }

top_100_cities = city_data[0...100].sort{|x,y| x[3] <=> y[3] }

CSV.open("#{ARGV[0][0..-5]}-medians.csv", "wb") do |csv|
  csv << ["City", "State", "Median Price"]
  top_100_cities.each do |city|
    csv << [city[0], city[1], city[3].to_s]
  end
end
