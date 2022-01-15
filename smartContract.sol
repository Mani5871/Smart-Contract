// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract smartContract
{
    struct Details
    {
        string owner;
        uint256 weiAmount;
        uint256 dollars;
        bool cap100;
    }

    mapping(address => uint256) public personToAmount;
    mapping(address => Details) public memberDetails;
    address[] addressArray;
    
    function deposit(string memory name) public payable
    {
        uint256 usd = weiToUsd(msg.value);
        require(usd >= 50, "Minimum 50 dollars amount it required");
        personToAmount[msg.sender] += msg.value;
        addressArray.push(msg.sender);

        Details memory person;

        person.owner = name;
        person.weiAmount = msg.value;
        person.dollars = usd;
        
        if(usd >= 100)
            person.cap100 = true;
        else
            person.cap100 = false;

        memberDetails[msg.sender] = person;
    }

    function weiToUsd(uint256 weiAmount) public view returns(uint256)
    {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int256 answer,  ,  , ) = pricefeed.latestRoundData();

        uint8 decimals = pricefeed.decimals();

        uint256 dollars = (uint256(answer) / (10 ** decimals)) * weiAmount;
        return dollars / (10 ** 18);
    }

    function withdraw() payable public {
        // payable(msg.sender.transfer(receiver.balance));
        // msg.sender.transfer(address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
    }

    // function sendAmount() public
    // {
    //     address toAddress = 0x90E3EC58Eb437204ad071339d6CE97740e7eadd0;
    //     payable(0x90E3EC58Eb437204ad071339d6CE97740e7eadd0).transfer(0.01 ether);

    // }
    // 326270000000

    function sendAmount(string memory fromName, string memory toName, uint256 amount) public payable
    {
        uint i;
        address toAddress;
        Details memory fromMember; 
        Details memory toMember;
        bool memberFound = false;

        for(i = 0; i < addressArray.length; i ++)
        {
            address memberAdress = addressArray[i];
            toMember = memberDetails[memberAdress];

            if(keccak256(bytes(toMember.owner)) == keccak256(bytes(toName)))
            {
                toAddress = memberAdress;
                break;
            }    
        }

        for(i = 0; i < addressArray.length; i ++)
        {
            address memberAddress = addressArray[i];
            fromMember = memberDetails[memberAddress];

            if(keccak256(bytes(fromMember.owner)) == keccak256(bytes(fromName)))
            {
                require(fromMember.weiAmount >= amount, "Funds not sufficient");
                fromMember.weiAmount -= amount;
                fromMember.dollars = weiToUsd(fromMember.weiAmount);
                toMember.weiAmount += amount;
                toMember.dollars = weiToUsd(toMember.weiAmount);

                memberFound = true;
                break;
            }

        }   
    }
}