// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@luckymachines/game-core/contracts/src/v0.0/GameController.sol";
import "./HexplorationBoard.sol";
import "./HexplorationZone.sol";
import "./HexplorationQueue.sol";
import "./HexplorationStateUpdate.sol";
import "./state/CharacterCard.sol";
import "./tokens/TokenInventory.sol";

contract HexplorationController is GameController {
    // functions are meant to be called directly by players by default
    // we are adding the ability of a Controller Admin or Keeper to
    // execute the game aspects not directly controlled by players
    bytes32 public constant VERIFIED_CONTROLLER_ROLE =
        keccak256("VERIFIED_CONTROLLER_ROLE");

    HexplorationStateUpdate GAME_STATE;

    // TODO:
    // Connect to Chainlink VRF for random seeds when needed
    // submit move + space choice
    // use / swap item

    /*
    Controller can access all game tokens with the following methods:

    function mint(
        string memory tokenType,
        uint256 gameID,
        uint256 quantity
    )

    function transfer(
        string memory tokenType,
        uint256 gameID,
        uint256 fromID,
        uint256 toID,
        uint256 quantity
    )
*/
    modifier onlyAdminVC() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(VERIFIED_CONTROLLER_ROLE, _msgSender()),
            "Admin or Keeper role required"
        );
        _;
    }

    constructor(address adminAddress) GameController(adminAddress) {}

    // Admin Functions

    function setGameStateUpdate(address gsuAddress)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        GAME_STATE = HexplorationStateUpdate(gsuAddress);
    }

    function addVerifiedController(address vcAddress)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(VERIFIED_CONTROLLER_ROLE, vcAddress);
    }

    // Admin or Keeper Interactions
    function runBoardUpdate(address boardAddress) public onlyAdminVC {
        HexplorationBoard(boardAddress).runUpdate();
    }

    function startGame(uint256 gameID, address boardAddress) internal {
        HexplorationBoard board = HexplorationBoard(boardAddress);
        require(board.gameState(gameID) == 0, "game already started");

        PlayerRegistry pr = PlayerRegistry(board.prAddress());
        board.lockRegistration(gameID);
        uint256 totalRegistrations = pr.totalRegistrations(gameID);
        string memory startZone = board.initialPlayZone(gameID);

        TokenInventory ti = TokenInventory(board.tokenInventory());
        // mint game tokens (maybe mint on demand instead...)
        // minting full game set here
        ti.DAY_NIGHT_TOKEN().mint("Day", gameID, 1);
        ti.DAY_NIGHT_TOKEN().mint("Night", gameID, 1);
        ti.DISASTER_TOKEN().mint("Earthquake", gameID, 1000);
        ti.DISASTER_TOKEN().mint("Volcano", gameID, 1000);
        ti.ENEMY_TOKEN().mint("Pirate", gameID, 1000);
        ti.ENEMY_TOKEN().mint("Pirate Ship", gameID, 1000);
        ti.ENEMY_TOKEN().mint("Deathbot", gameID, 1000);
        ti.ENEMY_TOKEN().mint("Guardian", gameID, 1000);
        ti.ENEMY_TOKEN().mint("Sandworm", gameID, 1000);
        ti.ENEMY_TOKEN().mint("Dragon", gameID, 1000);
        ti.ITEM_TOKEN().mint("Small Ammo", gameID, 1000);
        ti.ITEM_TOKEN().mint("Large Ammo", gameID, 1000);
        ti.ITEM_TOKEN().mint("Batteries", gameID, 1000);
        ti.ITEM_TOKEN().mint("Shield", gameID, 1000);
        ti.ITEM_TOKEN().mint("Portal", gameID, 1000);
        ti.ITEM_TOKEN().mint("On", gameID, 1000);
        ti.ITEM_TOKEN().mint("Off", gameID, 1000);
        ti.ITEM_TOKEN().mint("Rusty Dagger", gameID, 1000);
        ti.ITEM_TOKEN().mint("Rusty Sword", gameID, 1000);
        ti.ITEM_TOKEN().mint("Rusty Pistol", gameID, 1000);
        ti.ITEM_TOKEN().mint("Rusty Rifle", gameID, 1000);
        ti.ITEM_TOKEN().mint("Shiny Dagger", gameID, 1000);
        ti.ITEM_TOKEN().mint("Shiny Sword", gameID, 1000);
        ti.ITEM_TOKEN().mint("Shiny Rifle", gameID, 1000);
        ti.ITEM_TOKEN().mint("Laser Dagger", gameID, 1000);
        ti.ITEM_TOKEN().mint("Laser Sword", gameID, 1000);
        ti.ITEM_TOKEN().mint("Laser Pistol", gameID, 1000);
        ti.ITEM_TOKEN().mint("Laser Rifle", gameID, 1000);
        ti.ITEM_TOKEN().mint("Glow stick", gameID, 1000);
        ti.ITEM_TOKEN().mint("Flashlight", gameID, 1000);
        ti.ITEM_TOKEN().mint("Flood light", gameID, 1000);
        ti.ITEM_TOKEN().mint("Nightvision Goggles", gameID, 1000);
        ti.ITEM_TOKEN().mint("Personal Shield", gameID, 1000);
        ti.ITEM_TOKEN().mint("Bubble Shield", gameID, 1000);
        ti.ITEM_TOKEN().mint("Frag Grenade", gameID, 1000);
        ti.ITEM_TOKEN().mint("Fire Grenade", gameID, 1000);
        ti.ITEM_TOKEN().mint("Shock Grenade", gameID, 1000);
        ti.ITEM_TOKEN().mint("HE Mortar", gameID, 1000);
        ti.ITEM_TOKEN().mint("Incendiary Mortar", gameID, 1000);
        ti.ITEM_TOKEN().mint("EMP Mortar", gameID, 1000);
        ti.ITEM_TOKEN().mint("Power Glove", gameID, 1000);
        ti.ITEM_TOKEN().mint("Remote Launch and Guidance System", gameID, 1000);
        ti.ITEM_TOKEN().mint("Teleporter Pack", gameID, 1000);
        ti.ITEM_TOKEN().mint("Campsite", gameID, 1000);
        ti.PLAYER_STATUS_TOKEN().mint("Stunned", gameID, 1000);
        ti.PLAYER_STATUS_TOKEN().mint("Burned", gameID, 1000);
        ti.ARTIFACT_TOKEN().mint("Engraved Tablet", gameID, 1000);
        ti.ARTIFACT_TOKEN().mint("Sigil Gem", gameID, 1000);
        ti.ARTIFACT_TOKEN().mint("Ancient Tome", gameID, 1000);
        ti.RELIC_TOKEN().mint("Relic 1", gameID, 1000);
        ti.RELIC_TOKEN().mint("Relic 2", gameID, 1000);
        ti.RELIC_TOKEN().mint("Relic 3", gameID, 1000);
        ti.RELIC_TOKEN().mint("Relic 4", gameID, 1000);
        ti.RELIC_TOKEN().mint("Relic 5", gameID, 1000);
        // Transfer day token to board
        ti.DAY_NIGHT_TOKEN().transfer("Day", gameID, 0, 1, 1);

        for (uint256 i = 0; i < totalRegistrations; i++) {
            uint256 playerID = i + 1;
            address playerAddress = pr.playerAddress(gameID, playerID);
            board.enterPlayer(playerAddress, gameID, startZone);
            // Transfer campsite tokens to players
            ti.ITEM_TOKEN().transfer("Campsite", gameID, 0, playerID, 1);
        }
        // set game to initialized
        board.setGameState(2, gameID);

        HexplorationQueue q = HexplorationQueue(board.gameplayQueue());

        uint256 qID = q.queueID(gameID);
        if (qID == 0) {
            qID = q.requestGameQueue(
                gameID,
                uint16(pr.totalRegistrations(gameID))
            );
        }
        q.startGame(qID);
    }

    // function moveThroughPath(
    //     string[] memory zonePath,
    //     uint256 gameID,
    //     uint256 playerID,
    //     address boardAddress
    // ) public onlyAdminVC {
    //     // TODO:
    //     // verify move is valid
    //     // pick tiles from deck
    //     HexplorationBoard board = HexplorationBoard(boardAddress);
    //     PlayerRegistry pr = PlayerRegistry(board.prAddress());
    //     address playerAddress = pr.playerAddress(gameID, playerID);
    //     require(
    //         pr.isRegistered(gameID, playerAddress),
    //         "player not registered"
    //     );

    //     HexplorationZone.Tile[] memory tiles = new HexplorationZone.Tile[](
    //         zonePath.length
    //     );
    //     for (uint256 i = 0; i < zonePath.length; i++) {
    //         tiles[i] = i == 0 ? HexplorationZone.Tile.Jungle : i == 1
    //             ? HexplorationZone.Tile.Plains
    //             : HexplorationZone.Tile.Mountain;
    //     }

    //     HexplorationBoard(boardAddress).moveThroughPath(
    //         zonePath,
    //         playerID,
    //         gameID,
    //         tiles
    //     );
    // }

    //Player Interactions
    function registerForGame(uint256 gameID, address boardAddress) public {
        HexplorationBoard board = HexplorationBoard(boardAddress);
        board.registerPlayer(msg.sender, gameID);
        CharacterCard(board.characterCard()).setStats(
            [4, 4, 4],
            gameID,
            msg.sender
        );
    }

    function submitAction(
        uint256 playerID,
        uint8 actionIndex,
        string[] memory options,
        string memory leftHand,
        string memory rightHand,
        uint256 gameID,
        address boardAddress
    ) public {
        HexplorationBoard board = HexplorationBoard(boardAddress);
        HexplorationQueue q = HexplorationQueue(board.gameplayQueue());
        PlayerRegistry pr = PlayerRegistry(board.prAddress());
        require(
            pr.playerAddress(gameID, playerID) == msg.sender,
            "PlayerID is not sender"
        );
        uint256 qID = q.queueID(gameID);
        if (qID == 0) {
            qID = q.requestGameQueue(gameID, pr.totalRegistrations(gameID));
        }
        require(qID != 0, "unable to set qID in controller");
        q.sumbitActionForPlayer(
            playerID,
            actionIndex,
            options,
            leftHand,
            rightHand,
            qID
        );
    }

    function chooseLandingSite(
        string memory zoneChoice,
        uint256 gameID,
        address boardAddress
    ) public {
        // game rule: player 2 chooses on multiplayer game
        HexplorationBoard board = HexplorationBoard(boardAddress);
        PlayerRegistry pr = PlayerRegistry(board.prAddress());
        require(pr.isRegistered(gameID, msg.sender), "player not registered");

        if (pr.totalRegistrations(gameID) > 1) {
            require(
                pr.playerID(gameID, msg.sender) == 2,
                "P2 chooses landing site"
            );
        }
        board.enableZone(zoneChoice, HexplorationZone.Tile.LandingSite, gameID);
        // set landing site at space on board
        board.setInitialPlayZone(zoneChoice, gameID);

        startGame(gameID, boardAddress);
    }

    // TODO: limit this to authorized game starters
    function requestNewGame(address gameRegistryAddress, address boardAddress)
        public
    {
        HexplorationBoard board = HexplorationBoard(boardAddress);
        board.requestNewGame(gameRegistryAddress);
    }

    function latestGame(address gameRegistryAddress, address boardAddress)
        public
        view
        returns (uint256)
    {
        return GameRegistry(gameRegistryAddress).latestGame(boardAddress);
    }
}
