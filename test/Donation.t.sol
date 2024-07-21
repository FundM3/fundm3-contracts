// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Donation.sol";

contract DonationTest is Test {
    Donation donation;
    address platformAddress = address(0x123);
    address recipient = address(0x456);
    address donor = address(this);

    function setUp() public {
        // Deploy the Donation contract
        donation = new Donation(platformAddress);
    }

    function testSuccessfulDonation() public {
        // Set up initial balances
        uint256 initialRecipientBalance = recipient.balance;
        uint256 initialPlatformBalance = platformAddress.balance;

        // Amount to donate
        uint256 amount = 1 ether;

        // Perform the donation
        donation.donate{value: amount}(payable(recipient));

        // Check balances after donation
        uint256 expectedPlatformFee = (amount * 3) / 100;
        uint256 expectedRecipientAmount = amount - expectedPlatformFee;

        assertEq(recipient.balance, initialRecipientBalance + expectedRecipientAmount, "Recipient did not receive correct amount");
        assertEq(platformAddress.balance, initialPlatformBalance + expectedPlatformFee, "Platform did not receive correct fee");
    }

    function testDonationWithZeroAmount() public {
        // Expect a revert when trying to donate zero amount
        vm.expectRevert("Donation must be greater than 0");
        donation.donate{value: 0}(payable(recipient));
    }

    function testDonationWithHighPercentage() public {
        // Update platform fee to 50% (edge case)
        donation.updatePlatformFeePercentage(50);

        // Set up initial balances
        uint256 initialRecipientBalance = recipient.balance;
        uint256 initialPlatformBalance = platformAddress.balance;

        // Amount to donate
        uint256 amount = 1 ether;

        // Perform the donation
        donation.donate{value: amount}(payable(recipient));

        // Check balances after donation
        uint256 expectedPlatformFee = (amount * 50) / 100;
        uint256 expectedRecipientAmount = amount - expectedPlatformFee;

        assertEq(recipient.balance, initialRecipientBalance + expectedRecipientAmount, "Recipient did not receive correct amount with high fee");
        assertEq(platformAddress.balance, initialPlatformBalance + expectedPlatformFee, "Platform did not receive correct fee with high fee");
    }

    function testUpdatePlatformAddress() public {
        address newPlatformAddress = address(0x789);
        donation.updatePlatformAddress(newPlatformAddress);

        // Check that the platform address was updated correctly
        assertEq(donation.platformAddress(), newPlatformAddress, "Platform address was not updated correctly");
    }

    function testUpdatePlatformFeePercentage() public {
        uint256 newFeePercentage = 5;
        donation.updatePlatformFeePercentage(newFeePercentage);

        // Check that the platform fee percentage was updated correctly
        assertEq(donation.platformFeePercentage(), newFeePercentage, "Platform fee percentage was not updated correctly");
    }
}
