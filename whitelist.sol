// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherWallet{
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function send() public payable{}

    receive() external payable {}

    fallback() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function withdraw(uint _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }


    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    // transfer ether to another address
    function transfer(address payable _to, uint _amount) external onlyOwner {
        _to.transfer(_amount);
    }  
    
    // Build a whitelist. 
    // Use mapping can lower gas fee. 
    mapping(address => bool) whitelistedAddresses;

    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

    modifier isWhitelisted(address _address) {
      require(whitelistedAddresses[_address], "Whitelist: You need to be whitelisted");
      _;
    }

    // Test if the address is in the list. 
    function test() public view isWhitelisted(msg.sender) returns(bool){
      return (true);
    }

    // Build the other transfer for only address in white list. 
    function transferOnlyWhiteList(address payable _to, uint _amount) external isWhitelisted(msg.sender){
        _to.transfer(_amount);
    }  
}