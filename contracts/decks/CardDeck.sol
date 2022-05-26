// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract CardDeck is AccessControlEnumerable {
    // This is an infinite deck, cards drawn are not removed from deck
    // We can set card "quantities" for desireable probability

    // controller role should be set to a controller contract
    // not used by default, provided if going to make custom deck with limited access
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    string[] private _cards;

    // mappings from card name
    // should all store same size array of values, even if empty
    mapping(string => string) public description;
    mapping(string => uint16) public quantity;
    mapping(string => int8[3]) public movementAdjust;
    mapping(string => int8[3]) public agilityAdjust;
    mapping(string => int8[3]) public dexterityAdjust;
    mapping(string => string[3]) public itemGain;
    mapping(string => string[3]) public itemLoss;
    mapping(string => string[3]) public handLoss;
    mapping(string => int256[3]) public movementX;
    mapping(string => int256[3]) public movementY;
    mapping(string => uint256[3]) public rollThresholds; // [0, 3, 4] what to roll to receive matching index of mapping
    mapping(string => string[3]) public outcomeDescription;
    mapping(string => uint256) public rollTypeRequired; // 0 = movement, 1 = agility, 2 = dexterity

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function addCards(
        string[] memory titles,
        string[] memory descriptions,
        uint16[] memory quantities
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            titles.length == descriptions.length &&
                titles.length == quantities.length,
            "array quantity mismatch"
        );
        for (uint256 i = 0; i < titles.length; i++) {
            // only add if not already added and set quantity is not 0
            string memory title = titles[i];
            if (quantity[title] == 0 && quantities[i] != 0) {
                _cards.push(title);
                description[title] = descriptions[i];
                quantity[title] = quantities[i];
            }
        }
    }

    // this function does not provide randomness,
    // passing the same random word will yield the same draw.
    // randomness should come from controller

    // pass along movement, agility, dexterity rolls - will use whatever is appropriate
    function drawCard(uint256 randomWord, uint256[3] memory rollValues)
        public
        view
        virtual
        returns (
            string memory,
            int8,
            int8,
            int8,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        uint256 cardIndex = randomWord % _cards.length;
        string memory card = _cards[cardIndex];
        // TODO:
        // find index of roll ()
        uint256 rollIndex = 0;
        uint256 rollType = rollTypeRequired[card];
        uint256 rollValue = rollValues[rollType];
        uint256[3] memory thresholds = rollThresholds[card];
        for (uint256 i = thresholds.length - 1; i >= 0; i--) {
            if (rollValue >= thresholds[i]) {
                rollIndex = i;
                break;
            }
            if (i == 0) {
                break;
            }
        }
        // match index with all attributes
        return (
            card,
            movementAdjust[card][rollIndex],
            agilityAdjust[card][rollIndex],
            dexterityAdjust[card][rollIndex],
            itemLoss[card][rollIndex],
            itemGain[card][rollIndex],
            handLoss[card][rollIndex],
            outcomeDescription[card][rollIndex]
        );
    }

    function getDeck() public view returns (string[] memory) {
        return _cards;
    }
}
