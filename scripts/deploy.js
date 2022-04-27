const hre = require("hardhat");

async function main() {

  const vrfSubscriptionId = 3409;
  const Raffle = await hre.ethers.getContractFactory("Raffle");
  const raffle = await Raffle.deploy(vrfSubscriptionId);

  await raffle.deployed();

  console.log("Raffle deployed to:", raffle.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
