pragma solidity ^0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract dappic is ERC721Full, Ownable {

    constructor () ERC721Full("dappic" ,"DPP") public {
    }

    struct picture {
        string ipfsHash;
        address publisher;
        string name;
        string description;
    }
    
    mapping (uint=>picture) public pictures;
    mapping (string => bool) ipfsHashUploaded;

    string public tokenURIPrefix = "https://dappic.glitch.me/curse?id=";

    function tokenURI2(uint _curseId) public view returns (string) {
        bytes32 tokenIdBytes;
        if (_curseId == 0) {
            tokenIdBytes = "0";
        } else {
            uint value = _curseId;
            while (value > 0) {
                tokenIdBytes = bytes32(uint256(tokenIdBytes) / (2 ** 8));
                tokenIdBytes |= bytes32(((value % 10) + 48) * 2 ** (8 * 31));
                value /= 10;
            }
        }

        bytes memory prefixBytes = bytes(tokenURIPrefix);
        bytes memory tokenURIBytes = new bytes(prefixBytes.length + tokenIdBytes.length);

        uint i;
        uint index = 0;
        
        for (i = 0; i < prefixBytes.length; i++) {
            tokenURIBytes[index] = prefixBytes[i];
            index++;
        }
        
        for (i = 0; i < tokenIdBytes.length; i++) {
            tokenURIBytes[index] = tokenIdBytes[i];
            index++;
        }
        
        return string(tokenURIBytes);
    }

    function updateTokenURIPrefix(string _tokenURIPrefix) public onlyOwner {
        tokenURIPrefix = _tokenURIPrefix;
    }

    function mintpicture(string _ipfsHash, string _name, string _description) public {
        require(!ipfsHashUploaded[_ipfsHash]);
        ipfsHashUploaded[_ipfsHash] = true;

        picture memory _picture = picture({ipfsHash: _ipfsHash, publisher: msg.sender, name: _name, description: _description});
        uint256 newpictureId = totalSupply() + 1;
        pictures[newpictureId] = _picture;
        _mint(msg.sender, newpictureId);
    }

}