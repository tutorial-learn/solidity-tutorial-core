import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const todoContract = await ethers.getContractFactory("ExpensiveTodoList");
  const todo = await todoContract.deploy(
    process.env.OWNER!,
    process.env.TOKEN_ADDR!
  );

  console.log("todoContract address:", todo.address);
}

main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
