// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function send() public payable{
    }
a
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
}

