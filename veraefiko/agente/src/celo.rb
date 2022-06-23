# author: rafael polo 

class Celo
  # a simple proof-of-concept celo-cli wrapper
  # in a future version might use Go or pure Nodejs libs
  
  def self.balance(wallet)
    `npx celocli account:balances #{wallet}`
  end
  
  def self.local_balance
      `npx celocli account:balances #{ENV['LQDT_WALLET']}`
    end
  end
  
  # {"USD"=>3.515337790239205, "EUR"=>3.1687936815240936, "REAL"=>16.74053086564363}
  def self.celoStableValues
    `npx celocli exchange:show`
      .scan(/=> (\d+) c(\w+)/)
      .map{|x,y| [y,(x.to_f/1000000000000000000).round(3)]}
      .to_h
  end
  
  #  {"USD"=>4.786, "EUR"=>5.33, "REAL"=>1.0}
  def self.exchangeRealValues
    celoValues = exchangeCeloValues()
    celoValues.map{|c,v| ["c#{c}", "R$#{(celoValues["REAL"]/v).round(3)}"]}.to_h    
  end
  
  def self.swap_to_real(amount)
    `npx celocli exchange:reals --from #{ENV['LQDT_WALLET']} --value #{amount * 10 ** 18} --privateKey #{ENV['PVT_KEY']}` 
  end

  def self.send(to, value)
    puts "Sending #{value} cReal to #{to}"
    begin      
      output = `celocli transfer:reals --from #{ENV['LQDT_WALLET']} --to #{to} --value #{value * 10 ** 18} --gasCurrency=cREAL --privateKey #{ENV['PVT_KEY']}`
    rescue Exception => e 
      puts e.message
    end    
    if output.index("Error")
      puts output
    end
    if output.index("done")
      puts "= sent ="
    end    
  end    
  
  # wip: use pure web3 functions reading local node
  def self.load_txs_from_wallet()
    since = Time.now - 600*600 = # last_known_valid_transaction
    get("http://explorer.celo.org/api?module=account&action=txlist&starttimestamp=#{since}&address=#{ENV['LQDT_WALLET']}")['result']
  end
  
  def self.generate_cMCO2_from_fees
    # from all available local wallet Celo Real 
    # https://github.com/mobiusAMM/swappa
    # todo: test more!
    # > swappa --registries=mobius --input cREAL --output cMCO2 --amount #{available_cbrl}
    # research: allbridge and Mobius
  end
  
  # wip: observe_payments
  # for each Web3Utils.load_txs_from_wallet
  #   when new income transfer tx
  #     order_id = Web3Utils.read_data_comment_from_raw_input(tx)
  #     order = Order.new(order_id) # => Web3Utils.read_contract_order(order_id)
  #     if order.valid? && !order.executed? && !order.is_too_late? # > 5 minutes 
  #       Huobi.execute_onchain_order(order)
  #     else 
  #       # order.refund!
  #   end
  # end

	
  private
	def self.get(url)
		body = HTTParty.get(url).body
		begin
			JSON.parse body
		rescue Exception => e 
			puts e.message
		end
  end

end