// This example code is designed to quickly deploy an example contract using Remix.

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract APIConsumer is ChainlinkClient {
  
    bytes32 public data;
    string public responseString;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    
    /**
     * Network: Kovan
     * Chainlink - 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
     * Chainlink - 29fa9aa13bf1468788b7cc4a500a45b8
     * Fee: 0.1 LINK
     */
    constructor() public {
        setPublicChainlinkToken();
        oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        jobId = "50fc4215f89443d185b061e5d7af9490";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }
    
    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     ************************************************************************************
     *                                    STOP!                                         * 
     *         THIS FUNCTION WILL FAIL IF THIS CONTRACT DOES NOT OWN LINK               *
     *         ----------------------------------------------------------               *
     *         Learn how to obtain testnet LINK and fund this contract:                 *
     *         ------- https://docs.chain.link/docs/acquire-link --------               *
     *         ---- https://docs.chain.link/docs/fund-your-contract -----               *
     *                                                                                  *
     ************************************************************************************/
    function requestVolumeData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "https://www.balldontlie.io/api/v1/players/237");
        
        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //      {"ETH":
        //          {"USD":
        //              {
        //                  ...,
        //                  "VOLUME24HOUR": xxx.xxx,
        //                  ...
        //              }
        //          }
        //      }
        //  }
        request.add("path", "first_name");
        
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
     
    function sendEther(address payable recipient) external {
        recipient.transfer(.01 ether);

    }
    
    function fulfill(bytes32 _requestId, bytes32 _data) public recordChainlinkFulfillment(_requestId)
    {
        data = _data;
        responseString = string(abi.encodePacked(data));
        // converts strings to bytes then checks if response from API == 'Lebron'.

        if(keccak256(abi.encodePacked((responseString))) == keccak256(abi.encodePacked(('Lebron')))){
            this.sendEther(0xCdd3e25bCaA12BE76fB6B96755039Ac558D5C7Ae);
        }
    }
    


}