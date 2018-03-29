pragma solidity ^0.4.21;

contract Ownable
{
    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPotentialOwner {
        require(msg.sender == potentialOwner);
        _;
    }

    function setOwner(address _new) public onlyOwner {
        emit NewPotentialOwner(owner, _new);
        potentialOwner = _new;
    }

    function confirmOwnership() public onlyPotentialOwner {
        emit NewOwner(owner, potentialOwner);
        owner = potentialOwner;
        potentialOwner = 0;
    }
}
