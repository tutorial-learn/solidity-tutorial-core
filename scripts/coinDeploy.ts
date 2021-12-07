import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const todoToken = await ethers.getContractFactory("TodoERC20");
  const coin = await todoToken.deploy("TODO", "TODO", process.env.OWNER!);

  console.log("todoCoin address:", coin.address);
}

main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
