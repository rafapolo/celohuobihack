# author: rafael polo

class Order
    # encapsulate on-chain order
    attr_accessor :order_id, :from, :to, :token, :chain, :value, :created_at
    
    def initialize(order_id)
      order = Web3Utils.read_contract_order(order_id)  
      @order_id = order.order_id
      @from = order.from
      @to = order.to
      @token = order.token
      @chain = order.chain
      @value = order.value
      @status = order.status
      @created_at = order.created_at
    end
    
    def too_old?
      # wip: created_at > Time.now - 8.minutes
      false
    end
    
    def valid?
      #wip: !self.too_old? && liquidity && availability && slipage_diff
      true
    end
end