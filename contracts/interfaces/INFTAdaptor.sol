pragma solidity ^0.4.24;


contract INFTAdaptor {
    function convertTokenId(uint256 _originTokenId) public returns (uint256);

    function tokenIdOut2In(uint256 _originTokenId) public view returns (uint256);

    function tokenIdIn2Out(uint256 _mirrorTokenId) public view returns (uint256);

    function approveOriginToken(address _bridge, uint256 _originTokenId) public;

    function ownerOfOrigin(uint256 _originTokenId) public view returns (address);

    function ownerOfMirror(uint256 _mirrorTokenId) public view returns (address);

    function isBridged(uint256 _originTokenId) public view returns (bool);

    function tieMirrorTokenToApostle(uint256 _mirrorTokenId, uint256 _apostleTokenId, address _owner) public;
}
