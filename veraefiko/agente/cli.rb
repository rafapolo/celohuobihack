# author: rafael polo

require "./src/huobi"
require "./src/web3_utils"
require 'openssl'
require 'open-uri'
require "json"
require 'zlib'
require "base64"
require "byebug"


class Cli
  # base for a command prompt
  
  def initialize
    dashboard 
  end
  
  def dashboard
    print_line
    puts "Agent VERAΞFIKO v0.1"
    huobi = Huobi.new(ENV["access_key"], ENV["secret_key"])
    
    print_line
    puts "Account #{huobi.account_id}"
    print_line

    balances = huobi.balances
    puts "#{balances["data"]["type"]} balance:" # spot
    # show non-zero balances
    if balances['data']['list'].select{|b| b['balance']!="0"}.size>0
      ap balances['data']['list'] 
    else 
      puts "(empty)" 
    end
    print_line

    last_trade = huobi.trade_detail('celousdt')["tick"]["data"].first 
    puts "last CELO #{last_trade["direction"]} at $#{last_trade["price"]} USDT"
    print_line
    pp huobi.market_detail('celousdt')["tick"]
    print_line
  end
  
  def print_line
    puts "="*30
  end

end

Cli.new
Huobi.stream_markets

# todo: observe_payments
# for each Web3Utils.load_txs_from_wallet
#   when new income transfer tx
#     order_id = Web3Utils.read_data_comment_from_raw_input(tx)
#     order = Order.new(order_id) # => Web3Utils.read_contract_order(order_id)
#     if order.valid? && !order.executed? && !order.is_too_late? # > 5 minutes 
#       Huobi.execute_onchain_order(order)
#     else 
#       order.refund!    
#   end
# end

# todo: 
# def generate_tokens metadata
  # we basicly select all usdt markets and calculate as BRL Real + @marketmaker_fee on a new Hash
  # see sample agente/ipfs/metadata.json
# end

# end