require "http"
require "json"

def getUrlAsJson(url)
	requested_set_response = HTTP.get(url).to_s
	request_json = JSON.parse(requested_set_response)
	return request_json
end

def getSortedSellOrders(json)
	sorted_sells = json["response"]["sell"].sort_by { |i| i["price"]}
	return sorted_sells
end

request_as_json = getUrlAsJson("http://warframe.market/api/get_orders/Set/Akbronco%20Prime%20Set")
puts getSortedSellOrders(request_as_json)
