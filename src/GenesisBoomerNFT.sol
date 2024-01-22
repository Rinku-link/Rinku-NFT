// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GenesisBoomerNFT is ERC721, ReentrancyGuard, Ownable {
    uint256 public constant MAX_SUPPLY = 21000;
    string public constant TOKEN_URI = "";
    bool public mintingEnabled = false;
    uint256 public mintPrice;
    uint256 public mintCap;
    uint256 public mintedSum;
    uint256 public totalSupply;

    // Mapping to keep track of addresses that have minted
    mapping(address => bool) public hasMinted;

    // Events
    event MintPriceChanged(uint256 newPrice);
    event MintingEnabled(uint256 mintCap);
    event MintingDisabled();
    event Minted(address to, uint256 tokenId);
    event GenesisBoomerProof(address indexed user, string message);

    constructor(uint256 _mintPrice) ERC721("GenesisBoomerNFT", "GBT") Ownable(msg.sender) {
        mintPrice = _mintPrice;

        // Pre-mint 15% of maxSupply
        uint256 preMintAmount = MAX_SUPPLY * 15 / 100;
        for (uint256 i = 1; i <= preMintAmount; i++) {
            _safeMint(owner(), i);
            totalSupply++;
        }
        emit Minted(owner(), totalSupply);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _baseURI();
    }

    function _baseURI() internal pure override returns (string memory) {
        return TOKEN_URI;
    }

    function setMintPrice(uint256 _newPrice) public onlyOwner {
        mintPrice = _newPrice;
        emit MintPriceChanged(_newPrice);
    }

    function enableMinting(uint256 _mintCap) public onlyOwner {
        mintedSum = 0;
        mintCap = _mintCap;
        mintingEnabled = true;
        emit MintingEnabled(_mintCap);
    }

    function disableMinting() public onlyOwner {
        mintingEnabled = false;
        emit MintingDisabled();
    }

    function mint() public payable nonReentrant {
        require(mintingEnabled, "Minting is not enabled");
        require(mintedSum < mintCap, "Exceeds mint cap");
        require(totalSupply + 1 <= MAX_SUPPLY, "Exceeds max supply");
        require(msg.value >= mintPrice, "Incorrect Ether value");
        require(!hasMinted[msg.sender], "Address has already minted");

        // Mark the sender as having minted
        hasMinted[msg.sender] = true;
        mintedSum++;
        totalSupply++;
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

    // User sign a message
    function signGenesisProof() public {
        require(hasMinted[msg.sender], "Mint Genesis Boomer NFT first");
        emit GenesisBoomerProof(msg.sender, "Me Brave Boomer!");
    }
}
