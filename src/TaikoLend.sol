// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // For collateral token support

contract TaikoLend is Ownable {
    struct Loan {
        uint256 amount;
        uint256 dueDate;
        bool isRepaid;
        bool isCollateralized;
    }

    mapping(address => Loan) public loans;
    mapping(address => uint256) public reputation; // Track user credit history

    uint256 public interestRate = 5; // 5% interest
    uint256 public loanDuration = 30 days;
    IERC20 public collateralToken;

    event LoanIssued(address indexed borrower, uint256 amount, uint256 dueDate, bool isCollateralized);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event InterestRateUpdated(uint256 newRate);
    event LoanDurationUpdated(uint256 newDuration);

    // Pass the deployer's address to Ownable constructor
    constructor(address _collateralToken) Ownable(msg.sender) {
        collateralToken = IERC20(_collateralToken); // Collateral token address
    }

    // Request a loan with optional collateralization
    function requestLoan(uint256 _amount, bool _collateralized) external {
        require(loans[msg.sender].amount == 0, "Existing loan must be repaid first");
        
        uint256 interest = (_amount * interestRate) / 100;
        uint256 totalAmount = _amount + interest;

        // Handle collateral if collateralized
        if (_collateralized) {
            require(collateralToken.transferFrom(msg.sender, address(this), _amount), "Collateral transfer failed");
        }

        loans[msg.sender] = Loan({
            amount: totalAmount,
            dueDate: block.timestamp + loanDuration,
            isRepaid: false,
            isCollateralized: _collateralized
        });

        emit LoanIssued(msg.sender, totalAmount, loans[msg.sender].dueDate, _collateralized);
    }

    // Repay the loan
    function repayLoan() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.amount > 0, "No loan to repay");
        require(msg.value >= loan.amount, "Insufficient repayment amount");
        require(!loan.isRepaid, "Loan already repaid");

        loan.isRepaid = true;
        reputation[msg.sender] += 1; // Increase borrower’s reputation

        if (loan.isCollateralized) {
            collateralToken.transfer(msg.sender, loan.amount); // Return collateral if applicable
        }

        payable(owner()).transfer(msg.value);

        emit LoanRepaid(msg.sender, msg.value);
    }

    // Governance functions
    function setInterestRate(uint256 _rate) external onlyOwner {
        interestRate = _rate;
        emit InterestRateUpdated(_rate);
    }

    function setLoanDuration(uint256 _duration) external onlyOwner {
        loanDuration = _duration;
        emit LoanDurationUpdated(_duration);
    }

    // View function to check loan status
    function getLoanStatus(address _borrower) external view returns (Loan memory) {
        return loans[_borrower];
    }
}
