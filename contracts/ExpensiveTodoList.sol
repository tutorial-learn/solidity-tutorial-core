// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "./TodoERC20.sol";

contract ExpensiveTodoList {
  // Storage state
  address private owner;
  address private todoCoinAddr;
  uint256 private nounce;
  uint256 private changeCount;
  uint256 private todoIdsTotalLength;
  uint256[] private todoIds;
  mapping(address => bool) private users;
  mapping(address => string) private nickNames;
  mapping(address => bool) private masters;
  mapping(address => address) private paires;
  mapping(uint256 => Todo) private todos;
  mapping(uint256 => uint256) private depositBucket;

  // Event
  event Join(string _nickName);
  event Change(uint256 _count);

  // Struct for todo
  struct Todo {
    uint256 id;
    address author;
    string nickName;
    string description;
    bool isFinish;
    uint256 createdAt;
    uint256 updatedAt;
    uint256 finishTime;
  }

  // Once executting
  constructor(address _owner, address _todoCoinAddr) {
    owner = _owner;
    users[_owner] = true;
    nickNames[_owner] = "master";
    masters[_owner] = true;
    nounce = 0;
    changeCount = 0;
    todoIdsTotalLength = 0;
    todoCoinAddr = _todoCoinAddr;
  }

  modifier onlyOwner() {
    require(owner == msg.sender, "your not owner");
    _;
  }

  modifier onlyUser() {
    require(users[msg.sender], "first of all, join!");
    _;
  }

  modifier onlyMine(uint256 _todoId) {
    require(todos[_todoId].id > 0, "not existed");
    require(todos[_todoId].author == msg.sender, "not yours");
    _;
  }

  modifier onlyAuthenticate(uint256 _todoId) {
    require(todos[_todoId].id > 0, "not existed");
    require(
      todos[_todoId].author == msg.sender || masters[msg.sender],
      "you don't have permission"
    );
    _;
  }

  // Needed Gas

  function setMaster(address _user) public onlyOwner {
    masters[_user] = true;

    emit Change(changeCount++);
  }

  function unsetMaster(address _user) public onlyOwner {
    delete masters[_user];

    emit Change(changeCount++);
  }

  function toggleFinish(uint256 _todoId) public onlyUser onlyMine(_todoId) {
    if (todos[_todoId].isFinish) {
      todos[_todoId].finishTime = 0;
    } else {
      todos[_todoId].finishTime = block.timestamp;
    }
    todos[_todoId].isFinish = !todos[_todoId].isFinish;

    emit Change(changeCount++);
  }

  function write(uint256 _amount, string memory _description) public onlyUser {
    uint256 todoId = uint256(
      keccak256(
        abi.encodePacked(block.timestamp, msg.sender, nounce, _description)
      )
    );
    todos[todoId] = Todo(
      todoId,
      msg.sender,
      nickNames[msg.sender],
      _description,
      false,
      block.timestamp,
      0,
      0
    );
    todoIds.push(todoId);
    nounce++;
    todoIdsTotalLength++;

    require(_amount > 0, "not enough amount");
    depositBucket[todoId] = _amount;
    TodoERC20(todoCoinAddr).burn(msg.sender, _amount, owner);

    emit Change(changeCount++);
  }

  function edit(uint256 _todoId, string memory _description)
    public
    onlyUser
    onlyMine(_todoId)
  {
    require(todos[_todoId].isFinish == false, "already finished");

    todos[_todoId].description = _description;
    todos[_todoId].updatedAt = block.timestamp;

    emit Change(changeCount++);
  }

  function remove(uint256 _todoId) public onlyUser onlyAuthenticate(_todoId) {
    // finished todo and then removing
    if (todos[_todoId].isFinish && todos[_todoId].author == msg.sender) {
      uint256 depositAmount = depositBucket[_todoId];
      TodoERC20(todoCoinAddr).mint(msg.sender, depositAmount, owner);
    }

    delete todos[_todoId];
    for (uint256 i = 0; i < todoIds.length; i++) {
      if (todoIds[i] == _todoId) {
        delete todoIds[i];
        todoIdsTotalLength--;
        break;
      }
    }

    emit Change(changeCount++);
  }

  function join(string memory _nickName) public {
    users[msg.sender] = true;
    nickNames[msg.sender] = _nickName;

    emit Join(_nickName);
  }

  function out() public onlyUser {
    delete users[msg.sender];
    if (masters[msg.sender]) {
      delete masters[msg.sender];
    }

    for (uint256 i = 0; i < todoIds.length; i++) {
      if (todos[todoIds[i]].author == msg.sender) {
        delete todos[todoIds[i]];
        delete todoIds[i];
        todoIdsTotalLength--;
      }
    }

    emit Change(changeCount++);
  }

  // Only read

  function readAll() public view returns (Todo[] memory) {
    Todo[] memory actualTodos = new Todo[](todoIdsTotalLength);

    uint256 j = 0;
    for (uint256 i = 0; i < todoIds.length; i++) {
      if (todoIds[i] != 0) {
        actualTodos[j] = todos[todoIds[i]];
        j++;
      }
    }
    return actualTodos;
  }

  function isJoin() public view returns (bool) {
    return users[msg.sender];
  }

  function isMaster() public view onlyUser returns (bool) {
    return masters[msg.sender];
  }

  function isOwner() public view onlyUser returns (bool) {
    return owner == msg.sender;
  }
}
