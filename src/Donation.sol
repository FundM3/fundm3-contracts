// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Donation is Ownable {
    address payable public platformAddress;
    uint256 public platformFeePercentage = 3;

    event DonationMade(
        address indexed donor, 
        address indexed recipient, 
        uint256 totalAmount, 
        uint256 recipientAmount, 
        uint256 fee
    );
    event PlatformAddressUpdated(address indexed newAddress);
    event PlatformFeePercentageUpdated(uint256 newPercentage);

    constructor(address payable _platformAddress) Ownable(msg.sender) {
        platformAddress = _platformAddress;
    }

    function donate(address payable recipient) external payable {
        require(msg.value > 0, "Donation must be greater than 0");

        uint256 platformFee = Math.mulDiv(msg.value, platformFeePercentage, 100);
        uint256 recipientAmount = msg.value - platformFee;

        // Transfer platform fee to platformAddress
        (bool feeSent, ) = platformAddress.call{value: platformFee}("");
        require(feeSent, "Failed to send platform fee");

        // Transfer remaining amount to recipient
        (bool recipientSent, ) = recipient.call{value: recipientAmount}("");
        require(recipientSent, "Failed to send donation to recipient");

        emit DonationMade(msg.sender, recipient, msg.value, recipientAmount, platformFee);
    }

    // Function to update the platform address
    function updatePlatformAddress(address payable _newPlatformAddress) external onlyOwner {
        // Add access control as needed
        platformAddress = _newPlatformAddress;
        emit PlatformAddressUpdated(_newPlatformAddress);
    }

    // Function to update the platform fee percentage
    function updatePlatformFeePercentage(uint256 _newPercentage) external onlyOwner {
        require(_newPercentage <= 100, "Fee percentage must be less than or equal to 100");
        // Add access control as needed
        platformFeePercentage = _newPercentage;
        emit PlatformFeePercentageUpdated(_newPercentage);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
