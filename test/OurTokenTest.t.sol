// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

interface MintableToken {
    function mint(address _address, uint256 value) external;
}

contract OurTokenTest is Test {
    uint256 public BOB_STARTING_AMOUNT = 100 ether;

    DeployOurToken public deployer;
    OurToken public ot;
    address public bob;
    address public alice;
    address public deployerAddress;

    function setUp() public {
        deployer = new DeployOurToken();
        ot = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        ot.transfer(bob, BOB_STARTING_AMOUNT);
    }

    /* test initial supplied ether is the total ether the token has */
    function testInitialSupply() public {
        assertEq(deployer.INITIAL_SUPPLY(), ot.totalSupply());
    }

    /* make sure users cannot mint the token */
    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ot)).mint(address(this), 1);
    }

    /* one user allows another user to spend tokens on their behalf */
    function testAllowances() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        vm.prank(bob);
        ot.approve(alice, initialAllowance);

        vm.prank(alice);
        ot.transferFrom(bob, alice, transferAmount);
        assertEq(ot.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
        assertEq(ot.balanceOf(alice), transferAmount);
    }
}
