# author: rafael polo

# ==============================
# Huobi Terminal / veraΞfiko
# ==============================
# Account 40337003
# ==============================
# spot balance:
# (empty)
# ==============================
# last CELO buy at $0.8637 USDT
# ==============================
# {"id"=>468375750,
#  "low"=>0.8405,
#  "high"=>0.9599,
#  "open"=>0.8629,
#  "close"=>0.8658,
#  "vol"=>96570.47165076,
#  "amount"=>107133.24710231682,
#  "version"=>468375750,
#  "count"=>2083}
# ==============================
# wss:// reading Huobi markets...
# ==============================
# ipfs:// publishing changes ...
# ==============================
# celo:// new income transfer!
# ==============================
# Order#2481 executed!
# ==============================
# ...

require "./src/huobi"
require "./src/web3_utils"
require 'openssl'
require 'open-uri'
require "json"
require 'zlib'
require "base64"

class Cli
  # base for a command prompt
  
  def initialize
    dashboard 
  end
  
  def dashboard
    print_line
    puts "Huobi Terminal / veraΞfiko"
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
#     order = Web3Utils.read_contract_order(order_id)
#     if order.is_too_late? # > 5 minutes 
#       refund!    
#     else 
#       Huobi.execute_onchain_order(order)
#   end
# end