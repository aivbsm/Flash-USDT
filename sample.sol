// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TokenVault {
    address public owner;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;

    struct UserInfo {
        uint256 balance;
        uint256 depositCount;
        uint256 withdrawCount;
        uint256 lastDepositTime;
        uint256 lastWithdrawTime;
    }

    mapping(address => UserInfo) private users;

    event Deposited(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");

        UserInfo storage user = users[msg.sender];

        user.balance += msg.value;
        user.depositCount += 1;
        user.lastDepositTime = block.timestamp;

        totalDeposits += msg.value;

        emit Deposited(
            msg.sender,
            msg.value,
            block.timestamp
        );
    }

    function withdraw(uint256 amount) external {
        UserInfo storage user = users[msg.sender];

        require(amount > 0, "Invalid amount");
        require(user.balance >= amount, "Insufficient balance");

        user.balance -= amount;
        user.withdrawCount += 1;
        user.lastWithdrawTime = block.timestamp;

        totalWithdrawals += amount;

        payable(msg.sender).transfer(amount);

        emit Withdrawn(
            msg.sender,
            amount,
            block.timestamp
        );
    }

    function getUserInfo(address account)
        external
        view
        returns (
            uint256 balance,
            uint256 depositCount,
            uint256 withdrawCount,
            uint256 lastDepositTime,
            uint256 lastWithdrawTime
        )
    {
        UserInfo memory user = users[account];

        return (
            user.balance,
            user.depositCount,
            user.withdrawCount,
            user.lastDepositTime,
            user.lastWithdrawTime
        );
    }

    function transferOwnership(address newOwner)
        external
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Invalid owner"
        );

        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(
            oldOwner,
            newOwner
        );
    }

    function emergencyWithdraw(uint256 amount)
        external
        onlyOwner
    {
        require(
            address(this).balance >= amount,
            "Insufficient vault balance"
        );

        payable(owner).transfer(amount);
    }

    function getVaultBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    receive() external payable {
        totalDeposits += msg.value;
    }
}