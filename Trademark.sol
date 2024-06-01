function withdraw() public {
    require(msg.sender == owner, "Only owner can withdraw");
    payable(owner).transfer(address(this).balance);
}

