pragma solidity ^0.4.24;

import "./SettingIds.sol";
import "./PausableDSAuth.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./interfaces/INFTAdaptor.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "./interfaces/IInterstellarEncoderV3.sol";


contract ERC721Adaptor is PausableDSAuth, SettingIds {

    /*
     *  Storage
    */
    bool private singletonLock = false;

    uint16 public producerId;

    ISettingsRegistry public registry;

    ERC721 public originNft;

    /*
    *  Modifiers
    */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    function initializeContract(ISettingsRegistry _registry, ERC721 _originNft, uint16 _producerId) public singletonLockCall {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
        registry = _registry;
        originNft = _originNft;
        producerId = _producerId;
    }


    function toMirrorTokenId(uint256 _originTokenId) public view returns (uint256) {
        uint128 mirrorObjectId = uint128(_originTokenId & 0xffffffffffffffffffffffffffffffff);

        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        address petBase = registry.addressOf(SettingIds.CONTRACT_PET_BASE);
        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        uint256 mirrorTokenId = interstellarEncoder.encodeTokenIdForOuterObjectContract(
            petBase, objectOwnership, address(originNft), mirrorObjectId, producerId);

        return mirrorTokenId;
    }

    function ownerInOrigin(uint256 _originTokenId) public view returns (address) {
        return ERC721(originNft).ownerOf(_originTokenId);
    }

    function toOriginTokenId(uint256 _mirrorTokenId) public view returns (uint256) {
        return (_mirrorTokenId & 0xffffffffffffffffffffffffffffffff);
    }

    function approveToBridge(address _bridge) public onlyOwner {
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        ERC721(objectOwnership).setApprovalForAll(_bridge, true);
    }

    function cancelApprove(address _bridge) public onlyOwner {
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        ERC721(objectOwnership).setApprovalForAll(_bridge, false);
    }

    function approveOriginToken(address _bridge, uint256 _originTokenId) public auth {
        ERC721(originNft).approve(_bridge, _originTokenId);
    }

    function getObjectClass(uint256 _originTokenId) public view returns (uint8) {
        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        uint256 mirrorTokenId = toMirrorTokenId(_originTokenId);
        return interstellarEncoder.getObjectClass(mirrorTokenId);
    }
}
