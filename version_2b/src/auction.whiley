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
   map<uint256> returns
} where (returns[bidder] + bid) <= MAX_UINT256

public Auction self = {seller: 0, bidder: 0, bid: 0, returns: [0; MAX_UINT160+1]}

public export method bid()
// New bid must be higher!
requires msg::value > self.bid
// Bidder cannot best themself
requires msg::sender != self.bidder
// Restrict bidder based on their history
requires self.returns[msg::sender] + msg::value <= MAX_UINT256
// Double check that bid has increased
ensures old(self.bid) < self.bid
// Double check bidder updated as expected
ensures self.bidder == msg::sender:
   // Calculate new return
   uint256 nret = self.returns[self.bidder] + self.bid
   address obidder = self.bidder
   // Update contract state
   (self.returns[obidder], self.bidder, self.bid) = (nret, msg::sender, msg::value)

public export method withdraw():
   // Determine amount returnable
   uint256 amount = self.returns[msg::sender]
   self.returns[msg::sender] = 0
   // Send it!
   evm::util::transfer(msg::sender,amount)

public export method end()
// Only seller can end the auction!
requires msg::sender == self.seller:
   // Transfer the winnings
   evm::util::transfer(self.seller,self.bid)
   