// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Trademark {
    struct TrademarkApplication {
        address applicant;
        string trademark;
        uint256 timestamp;
    }

    TrademarkApplication[] public applications;

    address public owner;
    uint256 public applicationFee;

    event TrademarkApplied(address indexed applicant, string trademark, uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, string trademark);
    event Withdrawal(address indexed owner, uint256 amount);

    constructor(uint256 _applicationFee) {
        owner = msg.sender;
        applicationFee = _applicationFee;
    }

    function applyForTrademark(string memory _trademark) public payable {
        require(msg.value >= applicationFee, "Insufficient fee");

        TrademarkApplication memory newApplication = TrademarkApplication({
            applicant: msg.sender,
            trademark: _trademark,
            timestamp: block.timestamp
        });

        applications.push(newApplication);
        emit TrademarkApplied(msg.sender, _trademark, block.timestamp);
    }

    function getApplications() public view returns (TrademarkApplication[] memory) {
        return applications;
    }

    function isOwner(address _applicant, string memory _trademark) public view returns (bool) {
        for (uint256 i = 0; i < applications.length; i++) {
            if (applications[i].applicant == _applicant && keccak256(bytes(applications[i].trademark)) == keccak256(bytes(_trademark))) {
                return true;
            }
        }
        return false;
    }

    function transferOwnership(address _newOwner, string memory _trademark) public {
        require(isOwner(msg.sender, _trademark), "Only the owner can transfer ownership");

        for (uint256 i = 0; i < applications.length; i++) {
            if (applications[i].applicant == msg.sender && keccak256(bytes(applications[i].trademark)) == keccak256(bytes(_trademark))) {
                applications[i].applicant = _newOwner;
                emit OwnershipTransferred(msg.sender, _newOwner, _trademark);
                break;
            }
        }
    }

    function withdraw(uint256 _amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 balance = address(this).balance;
        require(_amount <= balance, "Insufficient balance in contract");
        payable(owner).transfer(_amount);
        emit Withdrawal(owner, _amount);
    }
}

