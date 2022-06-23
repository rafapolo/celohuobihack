$(document).ready(function() {
  if (typeof window.ethereum !== 'undefined') {
      const showAccount = document.querySelector('.showAccount');
      const showBalance = document.querySelector('.showBalance');

      let currentAccount = null;
      
      //manage
      $('.auth').on('click', function(){
        if (window.ethereum.isMetaMask){
            try {
                connectToAccount();
            } catch (error) {
                console.error(error);
            }
        }
        return false;
      });
      
      function read_metadata(){
        // "https://gateway.ipfs.io/ipns/"
      }
      
      if (window.ethereum.isMetaMask) {
          console.log('MetaMask is installed!');
      }
        
      web3 = new Web3(window.ethereum);
      ethereum.on("connect", function initConnect(chainId) {
          console.log(chainId);
          return false;
      });

        //account manage
    		function handleAccountsChanged(accounts)
    		{
    			if (accounts.length === 0){
    				console.log('Please connect to MetaMask.');
    			}
    			else if(accounts[0] !== currentAccount){
    				currentAccount = accounts[0];
    				showAccount.innerHTML = currentAccount;
            handleAccountsBalance(currentAccount);
    			}
    		}
            
        //balance
        function handleAccountsBalance(account) {
          var balance = ethereum.request({
            method: 'eth_getBalance',
            params: [account, "latest"]
          }).then((result) => {
            console.log(result);
            showBalance.innerHTML = web3.utils.hexToNumberString(result);
            $(".auth").hide();
          }).catch(err=>console.log(err))

        }
        
      //init account
      function connectToAccount(){
        console.log("connecting...")
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
  }

});
