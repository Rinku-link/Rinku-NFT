// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract GenesisOAT is ERC721, ReentrancyGuard, Ownable {
    string public constant TOKEN_URI = "ipfs://";
    bool public mintingEnabled = true;
    uint256 public totalSupply;

    // Mapping to keep track of addresses that have minted
    mapping(address => bool) public hasMinted;

    // Events
    event MintingDisabled();
    event Minted(address to, uint256 tokenId);

    constructor() ERC721("GenesisOAT", "GOAT") Ownable(msg.sender) {}

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _baseURI();
    }

    function _baseURI() internal pure override returns (string memory) {
        return TOKEN_URI;
    }

    function disableMinting() public onlyOwner {
        mintingEnabled = false;
        emit MintingDisabled();
    }

    function mint() public payable nonReentrant {
        require(mintingEnabled, "Minting is not enabled");
        require(!hasMinted[msg.sender], "Address has already minted");

        // Mark the sender as having minted
        hasMinted[msg.sender] = true;
        uint256 newTokenId = totalSupply + 1;
        _safeMint(msg.sender, newTokenId);
        emit Minted(msg.sender, newTokenId);
    }

    // Withdraw function to allow owner to withdraw funds
    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        (bool success,) = owner().call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(from == address(0), "Transfer not allowed");
        super.transferFrom(from, to, tokenId);
    }
}
