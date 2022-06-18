# author: rafael polo

class Web3Utils
  attr_accessor :web3
  
  def initializer()
    web3 = Web3::Eth::Rpc.new host: 'localhost', port: 8545, 
      connect_options: { use_ssl: true, read_timeout: 120 } 
  end
  
  def balance(wallet)
    web3.eth.getBalance wallet 
  end
    
  def read_data_comment_from_raw_input(input)
    [input[265+1..input.size]].pack('H*').gsub("\x00", "")
  end

  def publish_json_metadata(metadata)
    ipfsed_path = "~/ipfs/veraefico" 
    File.write("#{ipfsed_path}/metadata.json")
  end

  # def get_by_block(block, from)
  #   block = web3.eth.getBlockByNumber block  
  #   block.transactions[0].from from
  # end  

  # CeloMento monitoring the income transactions is enough
  # def read_onchain_orders()
  #   triggered by the smart contract event
  # end
  # def monitor_events
  #   contract = web3.eth.contract(abi).at('0x');...
  # end

  # we considered to generate a per-user 
  # contract when having a valid kyc'ed wallet
  #
  # def generate_pix_contract
  # end

  # def deploy_contract
  #   nodejs and go lang have better libs for this
  # end

  # todo: query_graphql()
end