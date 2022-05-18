import uint256, MAX_UINT256 from evm::ints
import uint160, MAX_UINT160 from evm::ints
import address from evm::util
import evm::map with map
import evm::msg

// Identifies the seller
public address seller = 0
// Identifiers (current) highest bidder
public address bidder = 0
// Records (current) highest bid
public uint256 bid = 0
// Records reclaimable ether
public map<uint256> returns = [0; MAX_UINT160+1]
// Records whether auction has ended
public bool ended = false

public export method bid()
// New bid must be higher!
requires msg::value > bid && !ended
// Protected against multi-bid overflow
requires returns[msg::sender] + msg::value <= MAX_UINT256:
   // Update amount returnable to previous bidder
   returns[bidder] = returns[bidder] + bid
   // Set new highest bidder
   bidder = msg::sender
   bid = msg::value

public export method withdraw():
   // Determine amount returnable
   uint256 amount = returns[msg::sender]
   returns[msg::sender] = 0
   // Send it!
   evm::util::transfer(msg::sender,amount)

public export method end()
// Can end only if not already ended
requires !ended
// Only seller can end the auction!
requires msg::sender == seller:
   // End the auction
   ended = true
   // Transfer the winnings
   evm::util::transfer(seller,bid)
   