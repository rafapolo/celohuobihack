$(document).ready(function() {
  if (typeof window.ethereum !== 'undefined') {
      let currentAccount = null;
      
      if (window.ethereum.isMetaMask) {
        console.log('MetaMask is installed!');
      }      
      
      // connect wallet
      $('.auth').on('click', function(){
        if (window.ethereum.isMetaMask){
            try {
                window.web3 = new Web3(window.ethereum);
                connectToAccount();
            } catch (error) {
                console.error(error);
            }
        }
        return false;
      });
      
      function read_metadata(){
        // todo: get address from contract
        $.getJSON("https://ipfs.io/ipfs/QmR5RCD47Y4DiUcDso4hpt2fmbJ87gQyYUBMFD4ojBU5jY", function(data){
          console.log("fetching ipfs:// metadata ...")
        }).done(function(result) {
          console.log(result);
          $.each( result['data'] , function( tkn, val ) {
            $("#tokens").append( "<span class='token' id='" + tkn + "'>" + tkn.toUpperCase() + " - cR$" + parseFloat(val['valor']).toFixed(2) + "</span>" );
          });
        }).fail(function(jqXHR, status, error){
          console.log(error);
        });
      }
      
      function loadContract(){
        $.get( "./src/HybridEx_abi.json", function( data ) {
          console.log("contract abi:");
          console.log(data);
          const ABI = data;
          window.contract = new window.web3.eth.Contract(ABI, "0xd9145CCE52D386f254917e481eB44e9943F39138"); 
        });
      } 
            
      //account manage
  		function handleAccountsChanged(accounts)
  		{
  			if (accounts.length === 0){
  				console.log('Please connect to MetaMask.');
  			}
  			else if(accounts[0] !== currentAccount){
  				currentAccount = accounts[0];
          handleAccountsBalance(currentAccount);
          $(".showAccount").text(currentAccount);
          read_metadata();
  			}
  		}
          
      // get balance
      function handleAccountsBalance(account) {
        var balance = ethereum.request({
          method: 'eth_getBalance',
          params: [account, "latest"]
        }).then((result) => {
          $(".showBalance").text(window.web3.utils.hexToNumberString(result) + " cREAL");
          $(".auth").hide();
          $(".wallet").show();
        }).catch(err=>console.log(err))
      }
      
      //init account
      function connectToAccount(){
        ethereum.request({
          method: 'eth_accounts',
          params: {
            chainId: '0xa4ec',
            chainName: 'Celo',
            nativeCurrency: { name: 'Celo', symbol: 'CELO', decimals: 18 }, 
            rpcUrls: ['https://forno.celo.org'],
            blockExplorerUrls: ['https://explorer.celo.org/'],
            iconUrls: ['future']
          }
        })
        .then(handleAccountsChanged)
        .catch((err) => {
            console.error(err);
        });
      }
      ethereum.on('accountsChanged', handleAccountsChanged);
      
      // buy token
      $(document).on("click", '.token', function(){
        token = $(this).attr("id");
        window.contract.methods.addOrder(address,string,string,uint256):
        // todo: form
      })
  }

});
