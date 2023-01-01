// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {Test} from "./Test.sol";

contract InvariantTest is Test {

    struct FuzzSelector {
        address addr;
        bytes4[] selectors;
    }

    address[] private _excludedContracts;
    address[] private _excludedSenders;
    address[] private _targetedContracts;
    address[] private _targetedSenders;

    FuzzSelector[] internal _targetedSelectors;

    function excludeContract(address newExcludedContract_) internal {
        _excludedContracts.push(newExcludedContract_);
    }

    function excludeContracts() public view returns (address[] memory excludedContracts_) {
        require(_excludedContracts.length != uint256(0), "NO_EXCLUDED_CONTRACTS");
        excludedContracts_ = _excludedContracts;
    }

    function excludeSender(address newExcludedSender_) internal {
        _excludedSenders.push(newExcludedSender_);
    }

    function excludeSenders() public view returns (address[] memory excludedSenders_) {
        require(_excludedSenders.length != uint256(0), "NO_EXCLUDED_SENDERS");
        excludedSenders_ = _excludedSenders;
    }

    function targetContract(address newTargetedContract_) internal {
        _targetedContracts.push(newTargetedContract_);
    }

    function targetContracts() public view returns (address[] memory targetedContracts_) {
        require(_targetedContracts.length != uint256(0), "NO_TARGETED_CONTRACTS");
        targetedContracts_ = _targetedContracts;
    }

    function targetSelector(FuzzSelector memory newTargetedSelector_) internal {
        _targetedSelectors.push(newTargetedSelector_);
    }

    function targetSelectors() public view returns (FuzzSelector[] memory targetedSelectors_) {
        require(targetedSelectors_.length != uint256(0), "NO_TARGETED_SELECTORS");
        targetedSelectors_ = _targetedSelectors;
    }

    function targetSender(address newTargetedSender_) internal {
        _targetedSenders.push(newTargetedSender_);
    }

    function targetSenders() public view returns (address[] memory targetedSenders_) {
        require(_targetedSenders.length != uint256(0), "NO_TARGETED_SENDERS");
        targetedSenders_ = _targetedSenders;
    }

}
