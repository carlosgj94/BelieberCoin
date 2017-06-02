pragma solidity 0.4.11;

contract BelieberCoin{
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping ( address => uint256)) public allowance;

    //balanceOf[address] = 5;0xA215F5e64DeDBCB826C263d57e97b0f181a51dA3
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


contract admined {
  address public admin;

  function admined() {
    admin = msg.sender;
  }
  modifier onlyAdmin() {
    if(msg.sender != admin) throw;
    _; //this tells the progran to continue
  }

  function transferAdminship(address newAdmin) onlyAdmin {
    admin = newAdmin;
  }
}

contract BelieberCoinAdvanced is admined, BelieberCoin {
  function BelieberCoinAdvanced( uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralAdmin) BelieberCoin(0, tokenName, tokenSymbol, decimalUnits) {
    totalSupply = initialSupply;
    if(centralAdmin != 0)
      admin = centralAdmin;
    else
      admin = msg.sender;
    balanceOf[admin] = initialSupply;
    totalSupply = initialSupply;
  }

  function mintToken( address target, uint256 mintedAmount) onlyAdmin {
    balanceOf[target] += mintedAmount;
    totalSupply += mintedAmount;
    Transfer(0, this, mintedAmount);
    Transfer(this, target, mintedAmount);
  }
}
