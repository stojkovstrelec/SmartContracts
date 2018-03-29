pragma solidity ^0.4.21;

import "./Ownable.sol";

contract Pausable is Ownable {

    event EPause(); //address owner, string event
    event EUnpause();

    bool public paused = true;

    modifier whenNotPaused()
    {
        require(!paused);
        _;
    }

    function pause() public onlyOwner
    {
        paused = true;
        emit EPause();
    }

    function unpause() public onlyOwner
    {
        paused = false;
        emit EUnpause();
    }
}
