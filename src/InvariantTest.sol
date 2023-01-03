// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

contract InvariantTest {
    struct FuzzSelector {
        address addr;
        bytes4[] selectors;
    }

    address[] private _excludedContracts;
    address[] private _excludedSenders;
    address[] private _targetedContracts;
    address[] private _targetedSenders;

    string[] private _excludedArtifacts;
    string[] private _targetedArtifacts;

    FuzzSelector[] internal _targetedArtifactSelectors;
    FuzzSelector[] internal _targetedSelectors;

    function excludeArtifact(string memory newExcludedArtifact_) internal {
        _excludedArtifacts.push(newExcludedArtifact_);
    }

    function excludeArtifacts() public view returns (string[] memory excludedArtifacts_) {
        require(_excludedArtifacts.length != uint256(0), "NO_EXCLUDED_ARTIFACTS");
        excludedArtifacts_ = _excludedArtifacts;
    }

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

    function targetArtifact(string memory newTargetedArtifact_) internal {
        _targetedArtifacts.push(newTargetedArtifact_);
    }

    function targetArtifacts() public view returns (string[] memory targetedArtifacts_) {
        require(_targetedArtifacts.length != uint256(0), "NO_TARGETED_ARTIFACTS");
        targetedArtifacts_ = _targetedArtifacts;
    }

    function targetArtifactSelector(FuzzSelector memory newTargetedArtifactSelector_) internal {
        _targetedArtifactSelectors.push(newTargetedArtifactSelector_);
    }

    function targetArtifactSelectors() public view returns (FuzzSelector[] memory targetedArtifactSelectors_) {
        require(targetedArtifactSelectors_.length != uint256(0), "NO_TARGETED_ARTIFACT_SELECTORS");
        targetedArtifactSelectors_ = _targetedArtifactSelectors;
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
