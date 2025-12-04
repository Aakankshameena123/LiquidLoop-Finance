// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title LiquidLoop Finance
 * @notice A yield-looping DeFi contract where users can deposit tokens and earn rewards which automatically compound in a loop.
 * @dev Works with any ERC20 token. Interest rate is applied per compounding cycle.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract LiquidLoopFinance {
    IERC20 public stakingToken;
    address public admin;
    uint256 public interestRate;     // e.g. 500 = 5% (two decimals)
    uint256 public compoundInterval; // seconds per compounding cycle

    struct UserInfo {
        uint256 deposited;
        uint256 lastCompound;
    }

    mapping(address => UserInfo) public users;

    event Deposited(address indexed user, uint256 amount);
    event Compounded(address indexed user, uint256 reward);
    event Withdrawn(address indexed user, uint256 amount);
    event UpdatedIR(uint256 newRate);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor(
        address _token,
        uint256 _interestRate,
        uint256 _compoundInterval
    ) {
        stakingToken = IERC20(_token);
        interestRate = _interestRate;
        compoundInterval = _compoundInterval;
        admin = msg.sender;
    }

    /**
     * @notice Deposit tokens to start earning looping yield
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        stakingToken.transferFrom(msg.sender, address(this), amount);

        autoCompound(msg.sender);

        users[msg.sender].deposited += amount;
        emit Deposited(msg.sender, amount);
    }

    /**
     * @notice Internal auto-compounding logic to loop rewards based on time
     */
    function autoCompound(address user) internal {
        UserInfo storage info = users[user];

        if (info.deposited == 0 || block.timestamp < info.lastCompound + compoundInterval) {
            // Not eligible for compounding yet
            info.lastCompound = block.timestamp;
            return;
        }

        uint256 cycles = (block.timestamp - info.lastCompound) / compoundInterval;
        uint256 reward;

        for (uint256 i = 0; i < cycles; i++) {
            reward = (info.deposited * interestRate) / 10000;
            info.deposited += reward;
        }

        info.lastCompound = block.timestamp;
        emit Compounded(user, reward);
    }

    /**
     * @notice Withdraw some or full amount including compounded yield
     */
    function withdraw(uint256 amount) external {
        autoCompound(msg.sender);
        require(users[msg.sender].deposited >= amount, "Insufficient balance");

        users[msg.sender].deposited -= amount;
        stakingToken.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Admin can update interest rate
     */
    function updateInterestRate(uint256 newRate) external onlyAdmin {
        interestRate = newRate;
        emit UpdatedIR(newRate);
    }

    /**
     * @notice Get rewards pending for compounding (view only)
     */
    function previewReward(address user) external view returns (uint256) {
        UserInfo memory info = users[user];
        if (info.deposited == 0 || block.timestamp < info.lastCompound + compoundInterval) {
            return 0;
        }
        uint256 cycles = (block.timestamp - info.lastCompound) / compoundInterval;
        uint256 reward = (info.deposited * interestRate) / 10000 * cycles;
        return reward;
    }
}
