# Expand Existing Smart Contract Functionality

This bounty is focused on expanding the functionalities of the existing smart contract based on the Build Your First DApp module. The goal is to add two additional features to the contract: `Edit and Delete Quest` and `Quest Start and End Time`.

This contract is to develop decentralized application built on the Ethereum blockchain that allows users to participate in quests and earn rewards. The application is powered by a smart contract called **StackUp**, which handles the creation, management, and execution of quests.

_____________________________________________________________________________

## Contract Overview

The `StackUp` contract is designed to manage quests and player participation in a quest-based system. It allows the creation, joining, and submission of quests by players, as well as editing and deletion of quests by the admin.

### Structs and Enums

The contract defines the following struct and enum:

-   `PlayerQuestStatus`: Enum representing the status of a player's quest. It can be one of the following:
    
    -   `NOT_JOINED`: Player has not joined the quest.
    -   `JOINED`: Player has joined the quest.
    -   `SUBMITTED`: Player has submitted the quest.
-   `Quest`: Struct representing the details of a quest. It includes the following properties:
    
    -   `questId`: Unique identifier for the quest.
    -   `numberOfPlayers`: Number of players who joined the quest.
    -   `title`: Title of the quest.
    -   `reward`: Reward for completing the quest.
    -   `numberOfRewards`: Number of rewards available for the quest.
    -   `startTime`: Start time of the quest.
    -   `endTime`: End time of the quest.

### Contract Variables

The contract includes the following variables:

-   `admin`: Address of the contract admin.
-   `nextQuestId`: Next available quest ID.
-   `quests`: Mapping of quest IDs to `Quest` structs.
-   `playerQuestStatuses`: Mapping of player addresses and quest IDs to `PlayerQuestStatus`.

### Contract Functions

The contract provides the following functions:

-   `createQuest`: Creates a new quest with the specified details. Only the admin can call this function.
    
-   `joinQuest`: Allows a player to join a quest. The player must not have already joined or submitted the quest, and the quest must be within the start and end time boundaries.
    
-   `submitQuest`: Allows a player to submit a quest. The player must have previously joined the quest, and the quest must still be within the end time boundary.
    
-   `editQuest`: Allows the admin to edit the details of a quest, such as the title, reward, number of rewards, start time, and end time. The quest must exist, and the start time must be in the future while the end time must be after the start time.
    
-   `deleteQuest`: Allows the admin to delete a quest. The quest must exist.
    

### Modifiers

The contract includes the following modifiers:

-   `questExists`: Checks if a quest exists by verifying that the quest's reward is greater than 0.
    
-   `onlyAdmin`: Ensures that the caller is the admin of the contract before executing the function.
    

This contract provides the necessary functionality to manage quests and player participation in a quest-based system.

## Two Features Added to Contract
### Feature 1: Edit and Delete Quest

The first feature to be implemented is the ability to edit and delete quests. This feature provides the contract administrator with the flexibility to modify quest details or remove quests that are no longer valid or needed. The following code demonstrates the updated functions in the smart contract:

```
// Allows the admin to edit the details of a quest
function editQuest( uint256 questId, string calldata newTitle, uint8 newReward, uint256 newNumberOfRewards, uint256 newStartTime, uint256 newEndTime ) external onlyAdmin questExists(questId) 
{ require(newStartTime >= block.timestamp, "Start time must be in the future"); 
require(newEndTime > newStartTime, "End time must be after start time"); 
Quest storage thisQuest = quests[questId]; 
thisQuest.title = newTitle; 
thisQuest.reward = newReward; 
thisQuest.numberOfRewards = newNumberOfRewards; 
thisQuest.startTime = newStartTime; 
thisQuest.endTime = newEndTime; }

// Allows the admin to delete a quest
    function deleteQuest(uint256 questId) external onlyAdmin questExists(questId) {
        delete quests[questId];
    }
```

With these functions, the contract administrator can update quest details such as the title, number of players required, reward amount, and the number of rewards available. Additionally, the `deleteQuest` function allows the administrator to remove quests from the contract entirely.

### Feature 2: Quest Start and End Time
The second feature being added is the ability to set start and end times for each quest. This feature brings time-bound constraints to quests and ensures that participants can only join quests that are active. The updated code below showcases the changes made to incorporate this functionality: 

```
struct Quest {
    // Existing quest attributes
    string title;
    uint256 numPlayersRequired;
    uint256 rewardAmount;
    uint256 numRewardsAvailable;
    
    // New quest attributes
    uint256 startTime;
    uint256 endTime;
}

function createQuest(
    string memory title,
    uint256 numPlayersRequired,
    uint256 rewardAmount,
    uint256 numRewardsAvailable,
    uint256 startTime,
    uint256 endTime
) public onlyAdmin {
    Quest memory newQuest = Quest(
        title,
        numPlayersRequired,
        rewardAmount,
        numRewardsAvailable,
        startTime,
        endTime
    );
    quests.push(newQuest);
}

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

```
-   The `joinQuest` function allows players to join a quest. However, certain conditions must be met:
    
    -   The player must not have already joined or submitted the quest.
    -   The current time must be after or equal to the quest's start time.
    -   The current time must be before or equal to the quest's end time.
-   Similarly, the `submitQuest` function allows players to submit a quest. The following conditions must be satisfied:
    
    -   The player must have already joined the quest.
    -   The current time must be before or equal to the quest's end time.

These time validations ensure that players can only participate in and complete quests within the specified time frame. If a player tries to join or submit a quest outside the allowed time range, the respective function will throw an error.



