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
  uint256 minimumBalanceForAccounts = 5 finney;

  uint256 public sellPrice;
  uint256 public buyPrice;

  mapping (address => bool) public frozenAccount;
  event FrozenFund(address target, bool frozen);

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

  function freezeAccount(address target, bool freeze) onlyAdmin {
    frozenAccount[target] = freeze;
    FrozenFund(target, freeze);
  }

  //Override to add frozenAccounts
  function transfer(address _to, uint256 _value) {
    if(msg.sender.balance < minimumBalanceForAccounts) //This allows to change ether to BbC. It's dangerous!
      sell((minimumBalanceForAccounts - msg.sender.balance)/sellPrice);
    if(frozenAccount[msg.sender]) throw;
    if(balanceOf[msg.sender] < _value) throw;
    if(balanceOf[_to] + _value < balanceOf[_to]) throw;

    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    Transfer(msg.sender, _to, _value);
  }

  //Override to add frozenAccounts
  function transferFrom( address _from, address _to, uint256 _value) returns (bool success) {
    if(frozenAccount[_from]) throw;
    //End of the override
    if(balanceOf[_from] < _value) throw;
    if(balanceOf[_to] + _value < balanceOf[_to]) throw;
    if(_value > allowance[_from][msg.sender]) throw;
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    allowance[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);

    return true;
  }

  function setPrices( uint256 newSellPrice, uint256 newBuyPrice) onlyAdmin {
    sellPrice = newSellPrice;
    buyPrice = newBuyPrice;
  }

  function buy() payable {
    uint256 amount = (msg.value/(1 ether)) / buyPrice;
    if(balanceOf[this] < amount) throw;
    balanceOf[msg.sender] += amount;
    balanceOf[this] -= amount;

    Transfer(this, msg.sender, amount);
  }

  function sell(uint256 amount) {
    if(balanceOf[msg.sender] < amount) throw;
    balanceOf[this] += amount;
    balanceOf[msg.sender] -= amount;
    if(!msg.sender.send(amount * sellPrice * 1 ether))
      throw;
    else
      Transfer(msg.sender, this, amount);

  }

  function giveBlockreward() {
    balanceOf[block.coinbase] += 1;
  }

  bytes32 public currentChallenge;
  uint public timeOfLastProof;
  uint public dificulty = 10**32;

  function proofOfWork(uint nonce) {
    bytes8 n = bytes8(sha3(nonce, currentChallenge));

    if(n < bytes8(dificulty)) throw;
    uint timeOfLastBlock = (now - timeOfLastProof);
    if(timeOfLastBlock < 5 seconds) throw;

    balanceOf[msg.sender] += timeOfLastBlock / 60 seconds;
    dificulty = dificulty * 10 minutes / timeOfLastProof + 1;
    timeOfLastProof = now;
    currentChallenge = sha3(nonce, currentChallenge, block.blockhash(block.number-1));
  }

}
