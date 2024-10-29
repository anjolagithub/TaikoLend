// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol"; // Import the Forge testing framework
import "../src/TaikoLend.sol"; // Import your TaikoLend contract
import "../src/MockERC20.sol"; // Import the MockERC20 contract

contract TaikoLendTest is Test {
    TaikoLend public taikoLend;
    MockERC20 public mockToken;

    function setUp() public {
        // Create an instance of the mock ERC20 token
        mockToken = new MockERC20("Collateral", "COL", 18);
        
        // Deploy the TaikoLend contract with the mock token address
        taikoLend = new TaikoLend(address(mockToken));
        
        // Approve the TaikoLend contract to spend tokens on behalf of the test address
        mockToken.approve(address(taikoLend), type(uint256).max);
    }

    // Add your test functions here
   function testRequestLoan() public {
    uint256 loanAmount = 100 * 10**18; // Principal amount
    taikoLend.requestLoan(loanAmount, true);
    
    // Get the loan status after requesting the loan
    TaikoLend.Loan memory loan = taikoLend.getLoanStatus(address(this));
    
    // Calculate expected total amount to be repaid with interest
    uint256 expectedRepaymentAmount = loanAmount * 105 / 100; // 5% interest

    // Assert that the amount is as expected
    assertEq(loan.amount, expectedRepaymentAmount, "Loan amount does not match expected repayment amount.");
    
    // Optionally assert other properties if necessary
    assertTrue(!loan.isRepaid, "Loan should not be marked as repaid immediately after request.");
}

}
