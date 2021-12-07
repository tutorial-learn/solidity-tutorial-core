// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TodoERC20 is ERC20 {
  address private owner;

  constructor(
    string memory name,
    string memory symbol,
    address _owner
  ) ERC20(name, symbol) {
    owner = _owner;
  }

  modifier onlyOwner(address _owner) {
    require(_owner == owner, "only owner");
    _;
  }

  function mint(
    address to,
    uint256 value,
    address _owner
  ) external onlyOwner(_owner) {
    super._mint(to, value);
  }

  function burn(
    address to,
    uint256 value,
    address _owner
  ) external onlyOwner(_owner) {
    super._burn(to, value);
  }
}
