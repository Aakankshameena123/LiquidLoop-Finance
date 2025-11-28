1e8 decimals
}

contract LiquidLoopFinance {
    STRUCTS
    -------------------------------------------------------
    -------------------------------------------------------
    IERC20 public immutable collateralToken; e.g., USDC/DAI

    IPriceOracle public oracle;

    uint256 public constant MAX_LOAN_TO_VALUE = 70_000;  80%
    uint256 public constant PRECISION = 1e5;

    mapping(address => Position) public positions;

    address public owner;

    EVENTS
    -------------------------------------------------------
    -------------------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier positionExists() {
        require(positions[msg.sender].exists, "No position");
        _;
    }

    CONSTRUCTOR
    -------------------------------------------------------
    -------------------------------------------------------
    function _getCollateralValue(uint256 amount) internal view returns (uint256) {
        -------------------------------------------------------
    -------------------------------------------------------
    function openLoop(uint256 collateralAmount, uint256 loops) external {
        require(!positions[msg.sender].exists, "Already exists");
        require(loops > 0 && loops <= 10, "Loops too high");

        Main leverage loop
        for (uint256 i = 0; i < loops; i++) {
            uint256 borrowable = _maxBorrow(currentCollateral) - totalDebt;
            if (borrowable == 0) break;

            placeholder for real lending pool
            totalDebt += borrowable;

            *DEX logic not included; assume swap executed offchain*
            uint256 extraCollateral = borrowable / 2; -------------------------------------------------------
    -------------------------------------------------------
    function boostLoop(uint256 extraCollateral, uint256 moreLoops) external positionExists {
        require(moreLoops > 0 && moreLoops <= 10, "Bad loops");

        collateralToken.transferFrom(msg.sender, address(this), extraCollateral);

        Position storage p = positions[msg.sender];
        p.collateral += extraCollateral;

        uint256 totalDebt = p.debt;

        placeholder
            p.collateral += extraCol;
        }

        p.debt = totalDebt;
        p.loopCount += moreLoops;

        emit LoopExpanded(msg.sender, p.collateral, moreLoops);
    }

    EXIT LOOP
    Repay debt (assume repaid separately)
        -------------------------------------------------------
    -------------------------------------------------------
    function liquidate(address user) external {
        require(_healthFactor(user) < LIQUIDATION_THRESHOLD, "Healthy");

        Position memory p = positions[user];
        require(p.exists, "No position");

        uint256 seizeCollateral = (p.collateral * 90_000) / PRECISION; Liquidator receives bonus collateral
        collateralToken.transfer(msg.sender, seizeCollateral);

        -------------------------------------------------------
    -------------------------------------------------------
    function updateOracle(address newOracle) external onlyOwner {
        oracle = IPriceOracle(newOracle);
        emit OracleUpdated(newOracle);
    }
}
// 
Contract End
// 
