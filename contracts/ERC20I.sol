pragma solidity ^0.4.21;

/// @title Abstract Token, ERC20 token interface
contract ERC20I
{
    function name() constant public returns (string);
    function symbol() constant public returns (string);
    function decimals() constant public returns (uint8);
    function totalSupply() constant public returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
