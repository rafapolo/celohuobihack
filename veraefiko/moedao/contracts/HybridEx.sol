// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title HybridEx
 * @author rafael polo
 * description stores CEX orders on-chain as a privacy-protecting layer
 */

contract HybridEx {

   string public ipns_path = "QmaiqEDcRto8CGQSnqMDUHkotnKHjmApmHSJNustTApaYm";
   
   enum State { Waiting_Payment, Executed, Refunded }
   
   mapping (uint256 => Order) orders; 
   uint256 ordersCount = 0;

   struct Order { 
      uint256 order_id;
      address to;
      string token;
      string chain;
      uint256 amount;
      State state;
   }

   event OrderedAdded(
        address to,
        string chain,
        uint256 amount
    );


   function addOrder(
      address to,
      string calldata token,
      string calldata chain,
      uint256 amount) 
         external 
      {
         // Order memory order = Order(ordersCount++, to, token, chain, amount, State.Waiting_Payment); 
         // orders.push(order);

        uint256 orderId = ordersCount++;
        // to discuss: dont't store the original sender for privacy
        Order storage order = orders[orderId];
        order.order_id = orderId;
        order.to = to;
        order.token = token;
        order.chain = chain;
        order.amount = amount;
        // todo: order.livePeriod = block.timestamp + 5 minutes;

        emit OrderedAdded(to, chain, amount);

    }
    
    function getOrder(uint order_id) 
      public
      view
      returns (Order memory)
      {
         return orders[order_id];
      }
 
}