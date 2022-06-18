# author: rafael polo

require "httparty"
require "eventmachine"
require "faye"

class Huobi
  attr_reader :account_id, :marketmaker_fee
  @marketmaker_fee = 2/100 # 2%  
  
  def initialize(access_key = '', secret_key = '', signature_version = "2")
    raise "set Huobi API keys!" unless access_key && secret_key
    @access_key = access_key
    @secret_key = secret_key
    @signature_version = signature_version
    @uri = URI.parse "https://api.huobi.pro/"
    @header = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
    }
    @account_id = accounts['data'].first["id"]
  end

  # 1291 listed as 2022-06-14
  def symbols
    request("GET", "/v1/common/symbols", {})
  end

  def depth(symbol, type = "step0")
    params = {"symbol" => symbol, "type" => type}
    request("get", "/market/depth", params)
  end

  def history_kline(symbol, period, size = 150)
    params = {"symbol" => symbol, "period" => period, "size" => size}
    request("GET", "/market/history/kline", params)
  end

  def market_trade(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/depth", params)
  end

  def trade_detail(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/trade", params, false)
  end

  def history_trade(symbol, size = 200)
    params = {"symbol" => symbol, "size" => size}
    request("GET", "/market/history/trade", params, false)
  end

  def market_detail(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/detail", params, false)
  end

  def currencys
    params = {}
    request("GET", "/v1/common/currencys", params)
  end

  def accounts
    params = {}
    request("GET", "/v1/account/accounts", params)
  end
  
  def withdraw(address, currency, amount, fee)
    # https://huobiapi.github.io/docs/spot/v1/en/#create-a-withdraw-request
    params = {
      address: address, 
      currency: currency, 
      amount: amount,
      fee: fee
    }
    request("GET", "/v1/dw/withdraw/api/create", params)
  end

  def balances    
    # balances = {"account_id"=>account_id}
    request("GET", "/v1/account/accounts/#{@account_id}/balance", {})
    # ['data']['list']
  end

  def new_order(symbol, side, price, amount)
    params = {
        "account-id" => @account_id,
        "amount" => count,
        "price" => price,
        "source" => "api",
        "symbol" => symbol,
        "type" => "#{side}-limit"
    }
    request("POST", "/v1/order/orders/place", params)
  end


  def orders(symbol, start_date = nil, size = 100)
    params = {
        "symbol" => symbol,
        "states" => "submitted,partial-filled,partial-canceled,filled,canceled",
        "size" => size
    }
    if start_date
      params.merge!({"start-date" => start_date})
    end
    request("GET", "/v1/order/orders", params)
  end
  
  def open_orders(symbol, side)
    params = {
        "symbol" => symbol,
        "types" => "#{side}-limit",
        "states" => "pre-submitted,submitted,partial-filled,partial-canceled"
    }
    request("GET", "/v1/order/orders", params)
  end
  
  # todo: 
  # /v2/account/withdraw/quota
  # /v1/query/deposit-withdraw
  
  # beyond REST API
  
  # def generate_tokens metadata
  # we basicly select all usdt markets and calculate as BRL Real + @marketmaker_fee on a new Hash
  # see sample agente/ipfs/metadata.json
  # might add more metadata as provider_signature and updated_at 
  # end
  
  def execute_onchain_order(order)
    # {token, to, amount, chain}
    # last_token_price *= @bridging_fee
    # we need to improve the mechanism to consider the price variations
    self.new_order(@account_id, "#{token}usdt", "buy", last_token_price, amount)
  end
  
  # Websocket streaming
  def self.stream_markets
    # todo: stream all
    market = "celousdt"
    
    EM.run {
      ws = Faye::WebSocket::Client.new('wss://api.huobi.pro/ws')
  
      ws.on :open do |event|
        p :ws_open
        ws.send({"sub": "market.#{market}.detail", "id": "id1"}.to_json)
      end
  
      ws.on :message do |event|
        msg = JSON.parse(Zlib::GzipReader.new(StringIO.new event.data.pack("c*")).read)        
        # p msg
        if ts=msg["ping"]        
          pong = {"pong": ts}
          # puts pong
          ws.send(pong.to_json)
        end

        if tick=msg["tick"]
          p tick 
        end
      end
  
      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    }
  end

  private
  def request(request_method, path, params, should_sign = true)
    h = params
    if should_sign
      h = {
          "AccessKeyId" => @access_key,
          "SignatureMethod" => "HmacSHA256",
          "SignatureVersion" => @signature_version,
          "Timestamp" => Time.now.getutc.strftime("%Y-%m-%dT%H:%M:%S")
      }
      h = h.merge(params) if request_method == "GET"
      data = "#{request_method}\napi.huobi.pro\n#{path}\n#{URI.encode_www_form(hash_sort(h))}"
      h["Signature"] = sign(data)
    end
    url = "https://api.huobi.pro#{path}?#{URI.encode_www_form(h)}"
    
    result = [].to_json
    begin
      if request_method == "POST"
        result = HTTParty.post(url, headers: @header, body: JSON.dump(params)).body
      elsif request_method == "GET"
        result = HTTParty.get(url, headers: @header).body
      end
      JSON.parse result
      
    rescue Exception => e
      {"message" => 'error', "request_error" => e.message}
    end
  end

  def sign(data)
    Base64.encode64(OpenSSL::HMAC.digest('sha256', @secret_key, data)).gsub("\n", "")
  end

  def hash_sort(ha)
    Hash[ha.sort_by {|key, val| key}]
  end
end
