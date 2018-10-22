pragma solidity ^0.4.25;

import "./interfaces/IAuthority.sol";

contract StandardERC223Authority is IAuthority {

    mapping (address => bool) public whiteList;

    constructor(address[] _whitelists) public {
        for (uint i = 0; i < _whitelists.length; i ++) {
            whiteList[_whitelists[i]] = true;
        }
    }

    function canCall(
        address _src, address _dst, bytes4 _sig
    ) public view returns (bool) {
        return ( whiteList[_src] && _sig == bytes4(keccak256("mint(address,uint128)")) ) ||
        ( whiteList[_src] && _sig == bytes4(keccak256("burn(address,uint128)")) );
    }
}
