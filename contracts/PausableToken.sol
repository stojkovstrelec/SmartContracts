pragma solidity ^0.4.21;

import "./MintableToken.sol";
import "./Pausable.sol";

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is MintableToken, Pausable {

    function transferFrom(address _from, address _to, uint256 _value)
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value)
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue)
        public
        whenNotPaused
        returns (bool)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
        public
        whenNotPaused
        returns (bool)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

}
