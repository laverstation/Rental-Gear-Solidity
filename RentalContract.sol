// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract OutdoorEquipment {
    address public owner;
    uint256 private counter;

    constructor() {
        counter = 0;
        owner = msg.sender;
     }

    // Information about rental that was created
    struct rentalInfo {
        string name;
        string category;
        string imgUrl;
        uint256 timePeriod;
        uint256 pricePerDay;
        string description;
        string[] datesBooked;
        uint256 id;
        address renter;

    }
    // Create rental event and add on smart contract
    event rentalCreated (
        string name,
        string category,
        string imgUrl,
        uint256 timePeriod,
        uint256 pricePerDay,
        string description,
        string[] datesBooked,
        uint256 id,
        address renter
    );

    // Store date Booked on smart contract
    event newDatesBooked (
        string[] datesBooked,
        uint256 id,
        address booker,
        string category,
        string imgUrl
    );

    mapping(uint256 => rentalInfo) rentals;
    uint256[] public rentalIds;

    function addRentals(
        string memory name,
        string memory category,
        string memory imgUrl,
        uint256 timePeriod,
        uint256 pricePerDay,
        string memory description,
        string[] memory datesBooked
    ) public {
        require(msg.sender == owner, "Only owner of smart contract can put up rentals");
        rentalInfo storage newRental = rentals[counter];
        newRental.name = name;
        newRental.category = category;
        newRental.imgUrl = imgUrl;
        newRental.timePeriod = timePeriod;
        newRental.pricePerDay = pricePerDay;
        newRental.description = description;
        newRental.datesBooked = datesBooked;
        newRental.id = counter;
        newRental.renter = owner;
        rentalIds.push(counter);
        emit rentalCreated(
            name,
            category,
            imgUrl,
            timePeriod,
            pricePerDay,
            description,
            datesBooked,
            counter,
            owner);
        counter++;
    }

    function checkBookings(uint256 id, string[] memory newBookings) private view returns (bool){ 
        for (uint i = 0; i < newBookings.length; i++) {
            for (uint j = 0; j < rentals[id].datesBooked.length; j++) {
                if (keccak256(abi.encodePacked(rentals[id].datesBooked[j])) == keccak256(abi.encodePacked(newBookings[i]))) {
                    return false;
                }
            }
        }
        return true;
    }

    function addDatesBooked(uint256 id, string[] memory newBookings) public payable {
        require(id < counter, "No such Rental");
        require(checkBookings(id, newBookings), "Already Booked For Requested Date");
        require(msg.value == (rentals[id].pricePerDay * 1 ether * newBookings.length) , "Please submit the asking price in order to complete the purchase");
    
        for (uint i = 0; i < newBookings.length; i++) {
            rentals[id].datesBooked.push(newBookings[i]);
        }

        payable(owner).transfer(msg.value);
        emit newDatesBooked(newBookings, id, msg.sender, rentals[id].category,  rentals[id].imgUrl);
    }

    function getRental(uint256 id) public view returns (string memory, uint256, string[] memory){
        require(id < counter, "No such Rental");

        rentalInfo storage s = rentals[id];
        return (s.name,s.pricePerDay,s.datesBooked);
    }

}
