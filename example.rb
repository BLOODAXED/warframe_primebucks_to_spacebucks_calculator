require "http"
require "json"

def getUrlAsJson(url)
	requested_set_response = HTTP.get(url).to_s
	request_json = JSON.parse(requested_set_response)
	return request_json
end

### Returns the sell orders with the smallest price in the first index
def getSortedSellOrders(json)
	sorted_sells = json["response"]["sell"].sort_by { |i| i["price"]}
	return sorted_sells
end

### Returns buy orders with the largest price in the first index.
def getSortedBuyOrders(json)
    sorted_buys = json["response"]["buy"].sort_by { |i| i["price"]}
    return sorted_buys.reverse
end

def getHighBuyAndLowSell(array_of_buy, array_of_sell)    
    best_five = Array.new
    array_of_buy[0...5].each{ |a| best_five.push(a) }
    array_of_sell[0...5].each{ |b| best_five.push(b) }
    return best_five
end

def makeFile(file_name, contents)
    somefile = File.open(file_name, "w")
    somefile.puts contents
    somefile.close
end
def justThePrices(input)
    prices = Array.new
    input.each{ |a| prices.push( a["price"] ) }
    return prices
end

files           = ["sorted_sell.txt", "sorted_buy.txt", "best_ten.txt", "prices.txt"]
request_as_json = getUrlAsJson("http://warframe.market/api/get_orders/Set/Akbronco%20Prime%20Set")
sorted_sell     = getSortedSellOrders(request_as_json)
sorted_buy      = getSortedBuyOrders(request_as_json)
best_ten        = getHighBuyAndLowSell(sorted_buy, sorted_sell)
prices          = justThePrices(best_ten)

makeFile(files[0], sorted_sell)
makeFile(files[1], sorted_buy)
makeFile(files[2], best_ten)
makeFile(files[3], prices)

puts "create files:"
puts files

# puts "sell"
# puts sorted_sell
# puts "buy"
# puts sorted_buy
# puts "best 10"
# puts best_ten
