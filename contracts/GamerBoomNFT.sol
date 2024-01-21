// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GamerBoomNFT is ERC721Enumerable, ReentrancyGuard, Ownable {
    uint256 public maxSupply;
    uint256 public mintPrice;
    uint256 public mintCap;
    bool public mintingEnabled = false;

    // Mapping to keep track of addresses that have minted
    mapping(address => bool) public hasMinted;

    // Events
    event MintPriceChanged(uint256 newPrice);
    event MintingEnabled(uint256 mintCap);
    event MintingDisabled();
    event Minted(address to, uint256 tokenId);
    event UserSigned(address indexed user, string message);

    constructor(uint256 _maxSupply, uint256 _mintPrice) ERC721("GamerBoomNFT", "GBN") {
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;

        // Pre-mint 15% of maxSupply
        uint256 preMintAmount = maxSupply * 15 / 100;
        for (uint256 i = 0; i < preMintAmount; i++) {
            _safeMint(owner(), totalSupply() + 1);
            emit Minted(owner(), totalSupply());
        }
    }

    function setMintPrice(uint256 _newPrice) public onlyOwner {
        mintPrice = _newPrice;
        emit MintPriceChanged(_newPrice);
    }

    function enableMinting(uint256 _mintCap) public onlyOwner {
        mintCap = _mintCap;
        mintingEnabled = true;
        emit MintingEnabled(_mintCap);
    }

    function disableMinting() public onlyOwner {
        mintingEnabled = false;
        emit MintingDisabled();
    }

    function mint(uint256 _amount) public payable nonReentrant {
        require(mintingEnabled, "Minting is not enabled");
        require(_amount <= mintCap, "Exceeds mint cap");
        require(totalSupply() + _amount <= maxSupply, "Exceeds max supply");
        require(msg.value >= mintPrice * _amount, "Incorrect Ether value");
        require(!hasMinted[msg.sender], "Address has already minted");

        for (uint256 i = 0; i < _amount; i++) {
            uint256 newTokenId = totalSupply() + 1;
            _safeMint(msg.sender, newTokenId);
            emit Minted(msg.sender, newTokenId);
        }

        // Mark the sender as having minted
        hasMinted[msg.sender] = true;
    }

    // Withdraw function to allow owner to withdraw funds
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // User sign a message
    function signMessage(string memory message) public {
        emit UserSigned(msg.sender, message);
    }
}
