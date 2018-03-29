pragma solidity ^0.4.21;

import "./PausableToken.sol";

contract Workcoin is PausableToken {

    address internal seller;

    /**
        @dev modified pausable/trustee seller contract
    */
    function transfer(address _to, uint256 _value) public
        returns (bool)
    {
        if(paused) {
            require(seller == msg.sender);
            return super.transfer(_to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    function sendToken(address _to, uint256 _value) public onlyOwner
        returns (bool)
    {
        require(_to != address(0x0));
        require(_value <= balances[this]);
        balances[this] = sub(balances[this], _value);
        balances[_to] = add(balances[_to], _value);
        emit Transfer(this, _to, _value);
        return true;
    }


    function setSeller(address _seller) public onlyOwner {
        seller = _seller;
    }

    /** @dev transfer ethereum from contract */
    function transferEther(address _to, uint256 _value)
        public
        onlyOwner
        returns (bool)
    {
        _to.transfer(_value); // CHECK THIS
        return true;
    }

    /**
        @dev owner can transfer out any accidentally sent ERC20 tokens
    */
    function transferERC20Token(address tokenAddress, address to, uint256 tokens)
        public
        onlyOwner
        returns (bool)
    {
        return ERC20(tokenAddress).transfer(to, tokens);
    }

    /**
        @dev mass transfer
        @param _holders addresses of the owners to be notified ["address_1", "address_2", ..]
     */
    function massTransfer(address [] _holders, uint256 [] _payments)
        public
        onlyOwner
        returns (bool)
    {
        uint256 hl = _holders.length;
        uint256 pl = _payments.length;
        require(hl <= 100 && hl == pl);
        for (uint256 i = 0; i < hl; i++) {
            transfer(_holders[i], _payments[i]);
        }
        return true;
    }

    /*
        @dev tokens constructor
    */
    function Workcoin() public
    {
        name = "Workcoin";
        symbol = "WRR";
        decimals = 18;
        version = "1.3";
        issue(this, 1e7 * 1e18);
    }

    function() public payable {}
}

contract Helper {

    function toString(address x) internal pure
        returns (string)
    {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }
}
