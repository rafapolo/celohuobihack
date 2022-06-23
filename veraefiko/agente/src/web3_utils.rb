# author: rafael polo

class Web3Utils
  attr_accessor :web3
  @ipfs_path = "./ipfs" 
  @ipfs_contract_addr = "QmPcwnX8eHUrP2n9XBFyTi6MnPhH7FcWMMLWVYt6FrkvBL"
  
  def initializer()
    # connect to local celo node
    web3 = Web3::Eth::Rpc.new host: 'localhost', port: 8545, 
      connect_options: { use_ssl: true, read_timeout: 120 } 
    # todo: check if local celo node and ipfs daemon are running
  end
  
  def balance(wallet)
    web3.eth.getBalance wallet 
  end
    
  def read_data_comment_from_raw_input(input)
    [input[265+1..input.size]].pack('H*').gsub("\x00", "")
  end
  
  # https://docs.ipfs.io/concepts/ipns/#example-ipns-setup-with-cli
  def exec_ipfs(command)
    begin
      JSON.parse(`cd #{@ipfs_path}; ipfs --encoding=json #{command}`)
    rescue Exception => e
      puts e.message
    end
  end

  # => https://ipfs.io/ipfs/QmSGsGXvntzHSVZoDvgA5VYzQE8hCUYQUB3ctZyhDPabnm
  def publish_json_metadata(metadata)
    File.write("#{@ipfs_path}/metadata.json")
    hash = exec_ipfs("add metadata.json")["Hash"]
    exec_ipfs("ipfs name publish /ipfs/#{hash}")
  end

  # wip: def read_contract_order(order_id)
    # hybridEx_abi_path = "../../moedao/artifacts/HybridEx_metadata.json" 
    # hybridex = web3.Eth.Contract.new(hybridEx_abi_path)
    #   .at @ipfs_contract_addr
    # hybridex.getOrder(order_id)
  # end

  # we considered to generate a per-user 
  # contract when having a valid kyc'ed wallet
  # with an encoded PIX transfer number, 
  # so we could easily provide a crypto ↠ fiat.
  #
  # def generate_pix_contract
  # end

  # def deploy_contract
  # end

  # todo: def query_graphql()
end