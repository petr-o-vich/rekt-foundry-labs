// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableGuardianBridge {
    error BadInput();
    error QuorumNotReached();

    uint256 public immutable threshold;
    mapping(uint8 => address) public guardians;
    mapping(bytes32 => bool) public accepted;

    constructor(address[] memory _guardians, uint256 _threshold) {
        if (_guardians.length == 0 || _threshold == 0 || _threshold > _guardians.length) revert BadInput();

        for (uint8 i = 0; i < _guardians.length; i++) {
            guardians[i] = _guardians[i];
        }

        threshold = _threshold;
    }

    // BUG: counts valid signatures, but does not enforce unique guardian indexes.
    function submit(bytes32 digest, uint8[] calldata idx, bytes[] calldata sigs) external {
        if (idx.length != sigs.length || idx.length == 0) revert BadInput();

        uint256 valid;
        for (uint256 i = 0; i < sigs.length; i++) {
            address signer = _recover(digest, sigs[i]);
            if (signer != address(0) && signer == guardians[idx[i]]) {
                valid++;
            }
        }

        if (valid < threshold) revert QuorumNotReached();
        accepted[digest] = true;
    }

    function _recover(bytes32 digest, bytes calldata sig) internal pure returns (address) {
        if (sig.length != 65) return address(0);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(0, calldataload(add(sig.offset, 64)))
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) return address(0);

        return ecrecover(digest, v, r, s);
    }
}
