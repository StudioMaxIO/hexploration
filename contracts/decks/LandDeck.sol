// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./ItemDeck.sol";

contract LandDeck is ItemDeck {
    constructor() ItemDeck() {}
}
