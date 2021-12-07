import { ethers } from "hardhat";

describe("ExpensiveTodoList", function () {
  it("Should return the new greeting once it's changed", async function () {
    const ExpensiveTodoList = await ethers.getContractFactory(
      "ExpensiveTodoList"
    );
    await ExpensiveTodoList.deploy("Hello, world!");
  });
});
