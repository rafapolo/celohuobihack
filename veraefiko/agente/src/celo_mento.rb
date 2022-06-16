# author: rafael polo 

class CeloMento
  # a simple celo-cli wrapper
  
  def self.balance(wallet)
    `npx celocli account:balances #{wallet}`
  end
  
  def self.celoStableValues
    # {"USD"=>3.515337790239205, "EUR"=>3.1687936815240936, "REAL"=>16.74053086564363}
    `npx celocli exchange:show`
      .scan(/=> (\d+) c(\w+)/)
      .map{|x,y| [y,(x.to_f/1000000000000000000).round(3)]}
      .to_h
  end
  
  def self.exchangeRealValues
    #  {"USD"=>4.786, "EUR"=>5.33, "REAL"=>1.0}
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
  
  # todo: use pure web3
  def self.load_txs_from_wallet() # working proof-of-concept
    since = Time.now - 600*600 = # last_known_valid_transaction
    get("http://explorer.celo.org/api?module=account&action=txlist&starttimestamp=#{since}&address=#{ENV['LQDT_WALLET']}")['result']
  end

  def self.generate_cMCO2_from_fees
    # can't exchange with mento? 
    # todo: find better route or plug other cex
  end
	
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