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
  # smart-node agent control
  
  def initialize
    dashboard 
  end
  
  #todo: prompt terminal
  # def method_missing 
    # loop { eval(gets(input)) }  
  
  def dashboard
    div
    puts "Agent VERAΞFIKO v0.1"
    huobi = Huobi.new(ENV["access_key"], ENV["secret_key"])
    
    div
    puts "Account #{huobi.account_id}"
    div

    balances = huobi.balances
    puts "#{balances["data"]["type"]} balance:" # spot
    # show non-zero balances
    if balances['data']['list'].select{|b| b['balance']!="0"}.size>0
      ap balances['data']['list'] 
    else 
      puts "(empty)" 
    end
    div

    last_trade = huobi.trade_detail('celousdt')["tick"]["data"].first 
    puts "last CELO #{last_trade["direction"]} at $#{last_trade["price"]} USDT"
    div
    pp huobi.market_detail('celousdt')["tick"]
    div
  end
  
  def div
    puts "="*30
  end

end

# serve local dApp folder
# for wallet integration dev purposes
def local_dapp!
  require 'webrick'
  puts "==> dApp @ http://localhost:2022"
  WEBrick::HTTPServer.new(Port: 2022, 
    DocumentRoot: File.expand_path("../dapp/dapp/")).start
  end
  
  
Cli.new
local_dapp!
# Huobi.stream_markets
# CeloMento.observe_payments


