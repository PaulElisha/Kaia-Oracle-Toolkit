// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../../script/DeployLottery.s.sol";
import "../../src/Lottery.sol";
import "../../script/HelperConfig.s.sol";

contract LotteryTest is Test {
    Lottery lottery;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callBackGasLimit;
    uint256 subId;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event LotteryEntered(address indexed player);
    event RequestedRandomWinner(uint256 requestId);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployLottery deployLottery = new DeployLottery();
        (lottery, helperConfig) = deployLottery.deployLottery();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callBackGasLimit = config.callBackGasLimit;
        subId = config.subId;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testLotteryInitializesInOpenState() public view {
        assert(lottery.getLotteryState() == Lottery.LotteryState.OPEN);
    }

    function testLotteryRevertsWhenNotEnoughEthSent() public {
        vm.prank(PLAYER);
        vm.expectRevert(Lottery.Lottery__InsufficientEthPassed.selector);
        lottery.enterLottery();
    }

    function testLotteryUpdatesPlayerWhenEnterLottery() public {
        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
        address recordedPlayer = lottery.getPlayer(0);
        assert(recordedPlayer == PLAYER);
    }

    function testEnteringLotteryEmitsEvent() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(lottery));
        emit LotteryEntered(PLAYER);
        lottery.enterLottery{value: entranceFee}();
    }

    function testDontAllowPlayersWhileLotteryIsCalculating() public {
        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        lottery.performUpkeep("");

        vm.expectRevert(Lottery.Lottery__NotOpen.selector);
        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
    }

    function checkUpkeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upKeepNeeded, ) = lottery.checkUpkeep(hex"");
        assert(!upKeepNeeded);
    }

    function checkUpkeepReturnsFalseIfLotteryIsNotOpen() public {
        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        lottery.performUpkeep("");

        (bool upKeepNeeded, ) = lottery.checkUpkeep(hex"");
        assert(!upKeepNeeded);
    }

    function testPerformUpkeepCanOnlyRunIfCheckUpKeepIsTrue() public {
        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        lottery.performUpkeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Lottery.LotteryState l_state = lottery.getLotteryState();

        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
        currentBalance = currentBalance + entranceFee;
        numPlayers = 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Lottery.Lottery__UpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                l_state
            )
        );

        lottery.performUpkeep("");
    }

    modifier LotteryEntered {
        vm.prank(PLAYER);
        lottery.enterLottery{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public LotteryEntered {
        vm.recordLogs();
        lottery.performUpkeep();
        Vm.log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        Lottery.LotteryState lotteryState = lottery.getLotteryState();
        assert(uint256(requestId) > 0)
        assert(uint256(lotteryState) == 1);
    }
}