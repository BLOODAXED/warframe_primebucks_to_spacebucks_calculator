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

### find the average and standard deviation of array_of_prices["price"] and remove any entries that are
### greater than or less than average +- num_delta * standard deviation.
def removeOutliers(array_of_prices,num_delta)
    std_deviation_of_prices = calculateStandardDevation(array_of_prices)
    average_of_prices = calculateAverage(array_of_prices)
    avg_puls_2_delta = (average_of_prices + num_delta*std_deviation_of_prices)
    avg_mins_2_delta = (average_of_prices - num_delta*std_deviation_of_prices)
    return array_of_prices.reject{|a| a["price"] > avg_puls_2_delta or a["price"] < avg_mins_2_delta}
end

### returns the average of all array_of_prices["price"] values
def calculateAverage(array_of_prices)
    temp_sum = array_of_prices.inject(0.0){ |sum, a| sum + a["price"]}
    average = temp_sum / (array_of_prices.size)
    return average
end

### returns the standard devision of all array_of_prices["price"] values
def calculateStandardDevation(array_of_prices)
    average = calculateAverage(array_of_prices)
    deviation = array_of_prices.inject(0.0){ |sum, a| sum + ((a["price"]-average)**2)}
    std_deviation = Math.sqrt(deviation / (array_of_prices.size - 1))
    return std_deviation
end

#given a hash with ["item_type"] and ["item_name"] constructs the warframe market url for the item
def constructItemURL(item_details)
    return "http://warframe.market/api/get_orders/#{item_details["item_type"]}/#{item_details["item_name"].gsub(/\s/,"%20")}"
end

# gets input from the user and locates a matching item if one exists.  If such an item doesn't exist,
# try to display options to the user that correspond with the string given by the user.
# returns the item's url.  May return nil/empty string if user cancels process early
def getItemFromUser()
    current_partial_item = ""
    list_of_all_items = getItemListFromMarketWebsite().sort_by { |i| i["item_name"]}
    array_to_display_to_user = Array.new
    matching_item = nil

    while(true)
        ## if current_partial_item is a perfect match, we are done
        if(matching_item = list_of_all_items.detect{|item| item["item_name"] == current_partial_item})
            puts "found a perfect match"
            break
        ## else check if current_partial_item is "", if so prompt user for brand new input
        elsif(current_partial_item == "")
            print "Please enter an item name or partial item name: "
            current_partial_item = gets.chomp
        ## else current_partial_item is something from the user and I need to try and present them with some options
        else
            puts "Currently haven't implemented partial matching"
            #Ask user for input, at least the first 3 letters of an item
            #Populate with the first 6? results that match those letters at the start of their name
            #If user inputs a certain special input return nil to exit the subroutine
            break
        end
    end

    users_item_url = constructItemURL(matching_item)
    puts users_item_url
end

def getItemListFromMarketWebsite()
    return getUrlAsJson("http://warframe.market/api/get_all_items_v2")
end

files           = ["sorted_sell.txt", "sorted_buy.txt", "best_ten.txt", "prices.txt"]
request_as_json = getUrlAsJson("http://warframe.market/api/get_orders/Set/Akbronco%20Prime%20Set")
sorted_sell     = getSortedSellOrders(request_as_json)
sorted_sell     = removeOutliers(sorted_sell,1.5)
sorted_buy      = getSortedBuyOrders(request_as_json)
sorted_buy      = removeOutliers(sorted_buy,1.5)
best_ten        = getHighBuyAndLowSell(sorted_buy, sorted_sell)
prices          = justThePrices(best_ten)

makeFile(files[0], sorted_sell)
makeFile(files[1], sorted_buy)
makeFile(files[2], best_ten)
makeFile(files[3], prices)

puts "create files:"
puts files

puts "testing user input section"
getItemFromUser()
