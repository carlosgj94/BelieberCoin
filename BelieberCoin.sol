pragma solidity 0.4.11;

contract BelieberCoin {
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping ( address => uint256)) public allowance;

    //balanceOf[address] = 5;
    string public standart = "BelieberCoin v1.0";
    string public name;
    string public symbol;
    uint8 public decimal;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);



    function BelieberCoin(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) {
      balanceOf[msg.sender] = initialSupply;
      totalSupply = initialSupply;
      decimal = decimalUnits;
      symbol = tokenSymbol;
      name = tokenName;
    }

    function transfer(address _to, uint256 _value) {
      if(balanceOf[msg.sender] < _value) throw;
      if(balanceOf[_to] + _value < balanceOf[_to]) throw;


      balanceOf[msg.sender] -= _value;
      balanceOf[_to] += _value;
      Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
      allowance[msg.sender][_spender] = _value;
      return true;
    }

    function transferFrom( address _from, address _to, uint256 _value) returns (bool success) {
      if(balanceOf[_from] < _value) throw;
      if(balanceOf[_to] + _value < balanceOf[_to]) throw;
      if(_value > allowance[_from][msg.sender]) throw;
      balanceOf[_from] -= _value;
      balanceOf[_to] += _value;
      allowance[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);

      return true;
    }
}
