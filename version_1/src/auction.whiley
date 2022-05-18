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
   uint256 bid
}

public Auction self = {seller: 0, bidder: 0, bid: 0}

public export method bid()
// New bid must be higher!
requires msg::value > self.bid:
   // Set new highest bidder
   self.bidder = msg::sender
   self.bid = msg::value

public export method end()
// Only seller can end the auction!
requires msg::sender == self.seller:
   // Transfer the winnings
   evm::util::transfer(self.seller,self.bid)
