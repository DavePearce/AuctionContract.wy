import uint256, MAX_UINT256 from evm::ints
import uint160, MAX_UINT160 from evm::ints
import address from evm::util
import evm::map with map
import evm::msg

type Auction is {
   // Identifies the seller
   address seller,
   // Identifiers (current) highest bidder
   address bidder,
   // Records (current) highest bid
   uint256 bid,
   // Records reclaimable ether
   map<uint256> returns,
   // Signals auction has ended
   bool ended
} where (returns[bidder] + bid) <= MAX_UINT256

public Auction self = {seller: 0, bidder: 0, bid: 0, returns: [0; MAX_UINT160+1], ended: false}

public export method bid()
// Cannot bid if auction over
requires !self.ended
// New bid must be higher!
requires msg::value > self.bid
// Bidder cannot best themself
requires msg::sender != self.bidder
// Restrict bidder based on their history
requires self.returns[msg::sender] + msg::value <= MAX_UINT256:
   // Calculate new return
   uint256 nret = self.returns[self.bidder] + self.bid
   self.bid = 0
   // Update amount returnable to previous bidder
   self.returns[self.bidder] = nret
   // Set new highest bidder
   self.bidder = msg::sender
   self.bid = msg::value

public export method withdraw():
   // Determine amount returnable
   uint256 amount = self.returns[msg::sender]
   self.returns[msg::sender] = 0
   // Send it!
   evm::util::transfer(msg::sender,amount)

public export method end()
// Cannot end auction more than once!
requires !self.ended
// Only seller can end the auction!
requires msg::sender == self.seller:
   // End the auction
   self.ended = true
   // Transfer the winnings
   evm::util::transfer(self.seller,self.bid)
   