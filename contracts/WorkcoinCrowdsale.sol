pragma solidity ^0.4.21;

//import "./SafeMath.sol";
//import "./Ownable.sol";
import "./Workcoin.sol";
//import "./Helper.sol";

contract WorkcoinCrowdsale is Ownable, SafeMath, Helper {

    // triggered on token sell
    event Invested(
        address indexed investorEthAddr,
        string  indexed currency,
        uint256 indexed investedAmount,
        string  txHash,
        uint256 toknesSent
    );
    // triggered when crowdsale period is over
    event CrowdSaleFinished();

    Workcoin public tokenAddress;

    uint256 public constant decimals = 18;
    uint256 DEC = 10 ** uint256(decimals);
    uint256 public receivedETH;
    uint256 public price;

    mapping (uint256 => Investment) public payments;

    /**
        @dev contract constructor
    */
    function WorkcoinCrowdsale(address _deployed) public {
        tokenAddress = Workcoin(_deployed);
        setPrice(10000);
    }

    function setPrice(uint256 _value) public
       onlyOwner
       returns (bool)
    {
        price = _value;
        return true;
    }

    struct Crowdsale {
        uint256 tokens;    // Tokens in crowdsale
        uint    startDate; // Date when crowsale will be starting, after its starting that property will be the 0
        uint    endDate;   // Date when crowdsale will be stop
        uint8   bonus;     // Bonus
    }

    Crowdsale public Crowd;

    /*
        @dev start crowdsale (any)
        @param _tokens - How much tokens will have the crowdsale - amount humanlike value (10000)
        @param _startDate - When crowdsale will be start - unix timestamp (1512231703)
        @param _endDate - When crowdsale will be end - humanlike value (7) same as 7 days
        @param _bonus - Bonus for the crowd - humanlive value (7) same as 7 %
    */
    function startCrowdsale(
        uint256 _tokens,
        uint    _startDate,
        uint    _endDate,
        uint8   _bonus
    )
        public
        onlyOwner
    {
        Crowd = Crowdsale (
            _tokens * DEC,
            _startDate,
            _startDate + _endDate * 1 days ,
            _bonus
            );
        saleStat = true;
    }

    /*
        @dev update crowdsale if smth incorrect
    */
    function updateCrowd(
        uint256 tokens,
        uint    startDate,
        uint    endDate,
        uint8   bonus
    )
        public
        onlyOwner
    {
        Crowd = Crowdsale(
            tokens,
            startDate,
            endDate,
            bonus
            );
    }

    /*
        @dev safe sales contoller
    */
    function confirmSell(uint256 _amount) internal view
        returns (bool)
    {
        if (Crowd.tokens < _amount) {
            return false;
        }
        return true;
    }

    /**
        @dev count summ with bonus
    */
    function countBonus(uint256 amount) internal view
        returns (uint256)
    {
        uint256 _amount = div(mul(amount, DEC), price);
        return _amount = add(_amount, withBonus(_amount, Crowd.bonus));
    }

    /**
        @dev sales manager
    */
    function paymentController(address sender, uint256 value) internal
        returns (uint256)
    {
        uint256 bonusValue = countBonus(value);
        bool conf = confirmSell(bonusValue);
        uint256 result;
        if (conf) {
            result = bonusValue;
            sell(sender, bonusValue);
            if (now >= Crowd.endDate) {
                saleStat = false;
                emit CrowdSaleFinished(); // if time is up
            }
        }
        else {
            result = Crowd.tokens;
            sell(sender, Crowd.tokens); // sell tokens which has been accessible
            saleStat = false;
            emit CrowdSaleFinished();  // if tokens sold
        }
        return result;
    }

    /**
        @dev sell function implements
    */
    function sell(address _investor, uint256 _amount) internal
    {
        Crowd.tokens = sub(Crowd.tokens, _amount);
        tokenAddress.transfer(_investor, _amount);
        //if(!ethOwner.send(msg.value)) revert();
    }

    /**
        @dev adding bonus
    */
    function withBonus(uint256 _amount, uint _percent) internal pure
        returns (uint256)
    {
        return div(mul(_amount, _percent), 100);
    }

    // safe storage for all txs
    uint256 public paymentId;

    function setId() internal {
        paymentId++;
    }

    function getId() public view
        returns (uint256)
    {
        return paymentId;
    }

    struct Investment {
        string  currency;
        address investorEthAddr;
        string  txHash;
        uint256 investedAmount;
        uint256 tokensSent;
        uint256 priceInUsd;
    }

    function paymentManager(
        string  currency,
        address investorEthAddr,
        string  txHash,
        uint256 investedAmount,
        uint256 tokensForSent
    )
        internal
    {
        require(bytes(currency).length != 0 &&
                investorEthAddr != 0x0 &&
                bytes(txHash).length != 0 &&
                investedAmount != 0 &&
                investorEthAddr != 0);
        setId();
        uint256 id = getId();
        uint256 tokensWithBonus = paymentController(investorEthAddr, tokensForSent);
        payments[id].currency = currency;
        payments[id].investorEthAddr = investorEthAddr;
        payments[id].txHash = txHash;
        payments[id].investedAmount = investedAmount;
        payments[id].tokensSent = tokensWithBonus;
        emit Invested(investorEthAddr, currency, investedAmount, txHash, tokensWithBonus);
    }

    function addPayment(
        string  currency,
        address investorEthAddr,
        string  txHash,
        uint256 investedAmount,
        uint256 tokensForSent
    )
        public onlyOwner
    {
        paymentManager(currency, investorEthAddr, txHash, investedAmount, tokensForSent);
    }

    bool internal saleStat = false;

    function switchSale() public onlyOwner
        returns(bool)
    {
        if(saleStat == true) {
            saleStat = false;
        } else {
            saleStat = true;
        }
        return saleStat;
    }

    function saleIsOn() view public
        returns(bool)
    {
        return saleStat;
    }

    /**
     @dev Function payments handler
    */
    function() public payable
    {
        assert(msg.value >= 1 ether / 10);
        require(Crowd.startDate <= now);

        if (saleIsOn() == true) {
            address(tokenAddress).transfer(msg.value); // transfer to the general contract
            paymentManager("eth", msg.sender, toString(tx.origin), msg.value, msg.value);
            receivedETH = add(receivedETH, msg.value);
        } else {
            revert();
        }
    }
}
