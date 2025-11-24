// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

abstract contract StdInvariant {
    address[] private _excludedContracts;
    address[] private _excludedSenders;
    address[] private _targetedContracts;
    address[] private _targetedSenders;

    string[] private _excludedArtifacts;
    string[] private _targetedArtifacts;

    string[] private _targetArtifactSelectorArtifacts;
    bytes4[] private _targetArtifactSelectorSelectors;

    address[] private _excludedSelectorAddresses;
    bytes4[] private _excludedSelectorSelectors;

    address[] private _targetedSelectorAddresses;
    bytes4[] private _targetedSelectorSelectors;

    address[] private _targetedInterfaceAddresses;
    string[] private _targetedInterfaceArtifacts;

    // Functions for users:
    // These are intended to be called in tests.

    function excludeContract(address newExcludedContract_) internal {
        _excludedContracts.push(newExcludedContract_);
    }

    function excludeSelector(address addr, bytes4 selector) internal {
        _excludedSelectorAddresses.push(addr);
        _excludedSelectorSelectors.push(selector);
    }

    function excludeSender(address newExcludedSender_) internal {
        _excludedSenders.push(newExcludedSender_);
    }

    function excludeArtifact(string memory newExcludedArtifact_) internal {
        _excludedArtifacts.push(newExcludedArtifact_);
    }

    function targetArtifact(string memory newTargetedArtifact_) internal {
        _targetedArtifacts.push(newTargetedArtifact_);
    }

    function targetArtifactSelector(string memory artifact, bytes4 selector) internal {
        _targetArtifactSelectorArtifacts.push(artifact);
        _targetArtifactSelectorSelectors.push(selector);
    }

    function targetContract(address newTargetedContract_) internal {
        _targetedContracts.push(newTargetedContract_);
    }

    function targetSelector(address addr, bytes4 selector) internal {
        _targetedSelectorAddresses.push(addr);
        _targetedSelectorSelectors.push(selector);
    }

    function targetSender(address newTargetedSender_) internal {
        _targetedSenders.push(newTargetedSender_);
    }

    function targetInterface(address addr, string memory artifact) internal {
        _targetedInterfaceAddresses.push(addr);
        _targetedInterfaceArtifacts.push(artifact);
    }

    // Functions for forge:
    // These are called by forge to run invariant tests and don't need to be called in tests.

    function excludeArtifacts() public view returns (string[] memory excludedArtifacts_) {
        excludedArtifacts_ = _excludedArtifacts;
    }

    function excludeContracts() public view returns (address[] memory excludedContracts_) {
        excludedContracts_ = _excludedContracts;
    }

    function excludeSelectors()
        public
        view
        returns (address[] memory excludedAddresses, bytes4[] memory excludedSelectors)
    {
        excludedAddresses = _excludedSelectorAddresses;
        excludedSelectors = _excludedSelectorSelectors;
    }

    function excludeSenders() public view returns (address[] memory excludedSenders_) {
        excludedSenders_ = _excludedSenders;
    }

    function targetArtifacts() public view returns (string[] memory targetedArtifacts_) {
        targetedArtifacts_ = _targetedArtifacts;
    }

    function targetArtifactSelectors()
        public
        view
        returns (string[] memory targetArtifact_, bytes4[] memory targetSelectors_)
    {
        targetArtifact_ = _targetArtifactSelectorArtifacts;
        targetSelectors_ = _targetArtifactSelectorSelectors;
    }

    function targetContracts() public view returns (address[] memory targetedContracts_) {
        targetedContracts_ = _targetedContracts;
    }

    function targetSelectors()
        public
        view
        returns (address[] memory targetedAddresses_, bytes4[] memory targetedSelectors_)
    {
        targetedAddresses_ = _targetedSelectorAddresses;
        targetedSelectors_ = _targetedSelectorSelectors;
    }

    function targetSenders() public view returns (address[] memory targetedSenders_) {
        targetedSenders_ = _targetedSenders;
    }

    function targetInterfaces()
        public
        view
        returns (address[] memory targetedAddresses_, string[] memory targetedArtifacts_)
    {
        targetedAddresses_ = _targetedInterfaceAddresses;
        targetedArtifacts_ = _targetedInterfaceArtifacts;
    }
}
