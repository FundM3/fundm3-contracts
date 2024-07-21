// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Donation {
    address public platformAddress;
    uint256 public platformFeePercentage = 3;

    constructor(address _platformAddress) {
        platformAddress = _platformAddress;
    }

    function donate(address payable recipient) external payable {
        require(msg.value > 0, "Donation must be greater than 0");

        uint256 platformFee = (msg.value * platformFeePercentage) / 100;
        uint256 remainingAmount = msg.value - platformFee;

        // Transfer platform fee to platformAddress
        (bool feeSent, ) = platformAddress.call{value: platformFee}("");
        require(feeSent, "Failed to send platform fee");

        // Transfer remaining amount to recipient
        (bool recipientSent, ) = recipient.call{value: remainingAmount}("");
        require(recipientSent, "Failed to send donation to recipient");
    }

    // Function to update the platform address
    function updatePlatformAddress(address _newPlatformAddress) external {
        // Add access control as needed
        platformAddress = _newPlatformAddress;
    }

    // Function to update the platform fee percentage
    function updatePlatformFeePercentage(uint256 _newPercentage) external {
        require(_newPercentage <= 100, "Fee percentage must be less than or equal to 100");
        // Add access control as needed
        platformFeePercentage = _newPercentage;
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
