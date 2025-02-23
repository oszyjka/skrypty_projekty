require 'nokogiri'
require 'httparty'
require 'uri'

USER_AGENTS = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
  "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0"
]

def fetch_amazon_product(search_product)
  query_hash = { "k" => search_product }
  search_url = "https://www.amazon.pl/s?" + URI.encode_www_form(query_hash)
  headers = {
    "User-Agent" => USER_AGENTS.sample,
    "Accept-Language" => "en-US,en;q=0.9",
    "Accept-Encoding" => "gzip, deflate, br",
    "Connection" => "keep-alive",
    "DNT" => "1",
    "Upgrade-Insecure-Requests" => "1"
  }

  retries = 3

  begin
    response = HTTParty.get(search_url, headers: headers, verify: false)

    if response.code == 503
      puts "Amazon blocked the request (503). Retrying..."
      raise "503 Error"  # Force a retry by raising an error
    elsif response.code != 200
      puts "Failed to fetch data. Status: #{response.code}. Retrying..."
      raise "Non-200 HTTP Response"  # Force a retry on any non-200 code
    end

    parsed_page = Nokogiri::HTML(response.body)

    results = parsed_page.css('div[role="listitem"]')
    if results.any?
      results.each do |product|
        name = product.at_css('h2.a-size-base-plus')
        if name && !name.text.strip.empty?
          name = name.text.strip
        else
          next
        end

        price = product.at_css('.a-price .a-offscreen')
        price = price&.text&.strip || "Price not found"

        rating = product.at_css('.a-icon-star-small span')
        rating = rating&.text&.strip || "Rating not found"

        puts "Product name: #{name}"
        puts "Price: #{price}"
        puts "Rating: #{rating}"
        puts "\n"
      end
    end
  rescue StandardError => e
    if retries > 0
      retries -= 1
      puts "Error occurred: #{e.message}. Retrying... (#{3 - retries} retries left)"
      sleep(5)
      retry
    else
      puts "Max retries reached. Could not fetch data."
    end
  end
end

fetch_amazon_product("laptop")