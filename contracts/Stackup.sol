// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract StackUp {
    // Enum to represent the status of a player's quest
    enum PlayerQuestStatus {
        NOT_JOINED, // Player has not joined the quest
        JOINED,     // Player has joined the quest
        SUBMITTED   // Player has submitted the quest
    }

    // Struct to store quest details
    struct Quest {
        uint256 questId;              // Unique identifier for the quest
        uint256 numberOfPlayers;      // Number of players who joined the quest
        string title;                 // Title of the quest
        uint8 reward;                 // Reward for completing the quest
        uint256 numberOfRewards;      // Number of rewards available for the quest
        uint256 startTime;            // Start time of the quest
        uint256 endTime;              // End time of the quest
    }

    address public admin;                                     // Address of the contract admin
    uint256 public nextQuestId;                               // Next available quest ID
    mapping(uint256 => Quest) public quests;                  // Mapping of quest IDs to Quest structs
    mapping(address => mapping(uint256 => PlayerQuestStatus)) public playerQuestStatuses; // Mapping of player address and quest ID to PlayerQuestStatus

    constructor() {
        admin = msg.sender;                                   // Assign the contract deployer as the admin
    }

    // Creates a new quest with the specified details
    function createQuest(
        string calldata title_,
        uint8 reward_,
        uint256 numberOfRewards_,
        uint256 startTime_,
        uint256 endTime_
    ) external onlyAdmin {
        quests[nextQuestId] = Quest({
            questId: nextQuestId,
            numberOfPlayers: 0,
            title: title_,
            reward: reward_,
            numberOfRewards: numberOfRewards_,
            startTime: startTime_,
            endTime: endTime_
        });
        nextQuestId++;
    }

    // Allows a player to join a quest
    function joinQuest(uint256 questId) external questExists(questId) {
        require(playerQuestStatuses[msg.sender][questId] == PlayerQuestStatus.NOT_JOINED, "Player has already joined/submitted this quest");
        require(block.timestamp >= quests[questId].startTime, "Quest has not started yet");
        require(block.timestamp <= quests[questId].endTime, "Quest has already ended");

        playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.JOINED;

        Quest storage thisQuest = quests[questId];
        thisQuest.numberOfPlayers++;
    }

    // Allows a player to submit a quest
    function submitQuest(uint256 questId) external questExists(questId) {
        require(playerQuestStatuses[msg.sender][questId] == PlayerQuestStatus.JOINED, "Player must first join the quest");
        require(block.timestamp >= quests[questId].startTime, "Quest has not started yet");
        require(block.timestamp <= quests[questId].endTime, "Quest has already ended");

        playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.SUBMITTED;
    }

    // Allows the admin to edit the details of a quest
    function editQuest(
        uint256 questId,
        string calldata newTitle,
        uint8 newReward,
        uint256 newNumberOfRewards,
        uint256 newStartTime,
        uint256 newEndTime
    ) external onlyAdmin questExists(questId) {
        require(newStartTime >= block.timestamp, "Start time must be in the future");
        require(newEndTime > newStartTime, "End time must be after start time");

        Quest storage thisQuest = quests[questId];
        thisQuest.title = newTitle;
        thisQuest.reward = newReward;
        thisQuest.numberOfRewards = newNumberOfRewards;
        thisQuest.startTime = newStartTime;
        thisQuest.endTime = newEndTime;
    }

    // Allows the admin to delete a quest
    function deleteQuest(uint256 questId) external onlyAdmin questExists(questId) {
        delete quests[questId];
    }

    // Modifier to check if a quest exists
    modifier questExists(uint256 questId) {
        require(quests[questId].reward > 0, "Quest does not exist");
        _;
    }

    // Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this operation");
        _;
    }
}
