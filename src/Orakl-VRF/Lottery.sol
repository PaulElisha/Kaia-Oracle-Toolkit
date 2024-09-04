// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@chainlink/contracts/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@chainlink/contracts/interfaces/AutomationCompatibleInterface.sol";

contract Lottery is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    /* Custom Errors */
    error Lottery__InsufficientEthPassed();
    error Lottery__TransferFailed();
    error Lottery__NotOpen();
    error Lottery__UpkeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 Lotterystate
    );

    /* Events Declarations */
    event LotteryEntered(address indexed player);
    event RequestedRandomWinner(uint256 requestId);
    event WinnerPicked(address indexed winner);

    /* Type Declarations */
    enum LotteryState {
        OPEN,
        CALCULATING
    }

    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callBackGasLimit;
    uint32 private constant NUM_WORDS = 1;
    address payable s_Winner;
    LotteryState private s_LotteryState;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;

    /* Functions */
    constructor(
        address vrfCoordinator,
        uint256 entranceFee,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callbackGasLimit;
        s_LotteryState = LotteryState(0);
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    function enterLottery() public payable {
        if (msg.value < i_entranceFee) revert Lottery__InsufficientEthPassed();
        if (s_LotteryState != LotteryState.OPEN) revert Lottery__NotOpen();
        s_players.push(payable(msg.sender));
        emit LotteryEntered(msg.sender);
    }

    function checkUpkeep(
        bytes memory /* checkData*/
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        uint256 sPlayersLength = s_players.length;
        bool isOpen = s_LotteryState == LotteryState.OPEN;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) >= i_interval);
        bool hasPlayers = (sPlayersLength > 0);
        bool hasBalance = (address(this).balance > 0);
        upkeepNeeded = (isOpen && timePassed && hasBalance && hasPlayers);
        return (upkeepNeeded, hex"");
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        // Request Random Words called Automatedly
        (bool upkeepNeeded, ) = checkUpkeep("");
        uint256 sPlayersLength = s_players.length;
        if (!upkeepNeeded)
            revert Lottery__UpkeepNotNeeded(
                address(this).balance,
                sPlayersLength,
                uint256(s_LotteryState)
            );

        s_LotteryState = LotteryState.CALCULATING;

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS, // block confirmations
                callbackGasLimit: i_callBackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        emit RequestedRandomWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] calldata randomWords
    ) internal override {
        uint256 sPlayerLength = s_players.length;
        uint256 indexWinner = randomWords[0] % sPlayerLength;
        address payable winner = s_players[indexWinner];
        s_Winner = winner;
        s_LotteryState = LotteryState.OPEN;
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(s_Winner);
        (bool success, ) = s_Winner.call{value: address(this).balance}("");
        if (!success) {
            revert Lottery__TransferFailed();
        }
    }

    function getEntrancefee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getWinner() public view returns (address) {
        return s_Winner;
    }

    function getLotteryState() public view returns (LotteryState) {
        return s_LotteryState;
    }

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getNumberOfplayers() public view returns (uint256) {
        return s_players.length;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getLatestTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }
}
