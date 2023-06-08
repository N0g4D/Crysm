// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract Crysm is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    
    uint24[12] public colors;

    /*
    uint8[12] public redValues;
    uint8[12] public greenValues;
    uint8[12] public blueValues;
    */

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Crysm", "CRSM") {
        colors[0]=0; //it should be by default, but remember WHY!
    }

    function _baseURI() internal pure override returns (string memory) {
        return "TODO - https://example.com/nft/";
    }

    function safeMint(address to, uint24[12] memory INcolors, string memory INuri) public onlyOwner {
        require(balanceOf(to)==0, "This address already owns a Crysm");

        for(uint i=0; i<12; i++) {
            colors[i]=INcolors[i];
        }

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, INuri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}