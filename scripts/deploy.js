const hre = require("hardhat");

async function main() {
  const StackUp = await hre.ethers.getContractFactory("StackUp");
  const stackUp = await StackUp.deploy();

  await stackUp.deployed();

  console.log("stackUp deployed to:", stackUp.address);

  let adminAddr = await stackUp.admin();
  console.log("admin address:", adminAddr);

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const endTime = currentTimestamp + 10 * 3600; // 10 hours

  await stackUp.createQuest(
    "Introduction to Hardhat",
    2,
    600, // numberOfRewards
    currentTimestamp, // startTime (current timestamp)
    endTime
  );

  await stackUp.createQuest(
    "Unit Testing with Hardhat",
    4,
    500, // numberOfRewards
    currentTimestamp, // startTime (current timestamp)
    endTime
  );

  await stackUp.createQuest(
    "Debugging and Deploying with Hardhat",
    5,
    400, // numberOfRewards
    currentTimestamp, // startTime (current timestamp)
    endTime
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
