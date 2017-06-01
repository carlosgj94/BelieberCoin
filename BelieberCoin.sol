pragma solidity 0.4.11;

contract BelieberCoin {
    mapping (address => uint256) public balanceOf;
    //balanceOf[address] = 5;

    function BelieberCoin(uint256 initialSupply) {
      balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address _to, uint256 _value) {
      balanceOf[msg.sender] -= _value;
      balanceOf[_to] += _value;
    }
}
