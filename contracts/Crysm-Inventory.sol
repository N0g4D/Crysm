// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "./GameOwner.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "./Crysm.sol";

contract CrysmInventory is ERC1155Supply, GameOwner, Pausable {

    mapping(uint24 => bool) private isLeadColorTaken;
    mapping(string => bool) private isColorCombinationTaken;

    Crysm private whiteCrysm;

    constructor() ERC1155("TODO-https://sunflower-land.com/play/erc1155/{id}.json") payable {
        gameRoles[msg.sender] = true;
    }

    function getLeadRedValue() public view returns (uint8) {
        
    }

    //I know this is UNSAFE, but it's just for testing. Maybe oraclizing later?
    function randomNumber() internal view returns (uint24) {
        return uint24(uint(blockhash(block.number - 1)));
    }

    function setURI(string memory newuri) public onlyOwner returns (bool) {
        _setURI(newuri);
        return true;
    }

    function crysMint(address to) public onlyGame returns (bool) {
        uint24[12] memory colors;

        //this sucks. it would be better iterate on leadColor gen to save gas (random reverts are not nice).
        //when there are not possibile combinations anymore, revert
        colors[0] = randomNumber(); 
        require(!isLeadColorTaken[(colors[0])], "Can't mint another Crysm with this lead color");

        string memory uri = Strings.toString(colors[0]);

        do {
            for(uint i=1; i<12; i++) {
                colors[i]=randomNumber();
                uri = string.concat(uri, "-");
                uri = string.concat(uri, Strings.toString(colors[i]));
            }
        } while(isColorCombinationTaken[uri]);

        isLeadColorTaken[colors[0]] = true;
        isColorCombinationTaken[uri] = true;

        //!!! check if "to" is already a Crysm owner !!!

        whiteCrysm.safeMint(to, colors, uri);
        return true;
    }

    function gameMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyGame returns (bool) {
        _mintBatch(to, ids, amounts, data);
        return true;
    }

    function gameBurn(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyGame returns (bool) {
        _burnBatch(to, ids, amounts);
        return true;
    }

    function gameTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyGame returns (bool) {
        _safeBatchTransferFrom(from, to, ids, amounts, data);
        return true;
    }

    function gameSetApproval(
        address owner,
        address operator,
        bool approved
    ) public onlyGame returns (bool) {
        _setApprovalForAll(owner, operator, approved);
        return true;
    }

    /**
     * Fetch supply for multiple tokens
     */
    function totalSupplyBatch(uint256[] memory ids)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory batchSupply = new uint256[](ids.length);

        for (uint256 i = 0; i < ids.length; ++i) {
            batchSupply[i] = totalSupply(ids[i]);
        }

        return batchSupply;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}

/*
contract Crysm is ERC1155 {
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant THORS_HAMMER = 2;
    uint256 public constant SWORD = 3;
    uint256 public constant SHIELD = 4;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**27, "");
        _mint(msg.sender, THORS_HAMMER, 1, "");
        _mint(msg.sender, SWORD, 10**9, "");
        _mint(msg.sender, SHIELD, 10**9, "");
    }
}
*/