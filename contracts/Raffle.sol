// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VRFv2Consumer is VRFConsumerBaseV2, Ownable {
  VRFCoordinatorV2Interface COORDINATOR;

  // Keeps track of wallets that have been added the drawing. Once a wallet is selected 
  // as a winner or runner-up, they are removed from this list in order to
  // prevent that same wallet from possibly being selected again.
  address[] public walletsInDrawing;

  // A lookup to check if a wallet is part of the drawing. Unlike walletsInDrawing, once
  // a wallet to added to this lookup, they will remain in this lookup, winner or not.
  mapping(address => bool) public isInDrawing;

  // Provide a lookup on the placement of the winner and runner-ups.
  mapping(uint => address) public winners;

  enum RAFFLE_STATE { CLOSED, OPEN, CALCULATING_WINNER }
  RAFFLE_STATE public raffleState;

  uint64 s_subscriptionId;

  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit = 100000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // retrieve 3 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords =  1;

  uint256[] public s_randomWords;
  uint256 public s_requestId;

  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_subscriptionId = subscriptionId;
    raffleState == RAFFLE_STATE.OPEN;
  }

  function addWallets(address[] memory addresses) external onlyOwner {
    for(uint256 i=0;i < addresses.length;i++) {
      // ignore any addresses that are already part of the drawing
      if(isInDrawing[addresses[i]]) {
        break;
      }

      walletsInDrawing.push(addresses[i]);
      isInDrawing[addresses[i]] = true;
    }
  }

  function requestRandomWords() external onlyOwner {
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }
  
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
  }
}
