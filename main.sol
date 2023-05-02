pragma solidity ^0.8.0;

contract SubscriptionService {
   address owner;
   uint recurringInterval;
   uint subscriptionFee;
   mapping(address => uint) public subscriptionExpiry;

   event SubscriptionRenewed(address subscriber, uint expiry);

   constructor(uint _recurringInterval, uint _subscriptionFee) {
      owner = msg.sender;
      recurringInterval = _recurringInterval;
      subscriptionFee = _subscriptionFee;
   }

   modifier onlyOwner() {
      require(msg.sender == owner, "Only the owner can access this function.");
      _;
   }

   modifier onlySubscriber() {
      require(subscriptionExpiry[msg.sender] > 0, "You are not subscribed to this service.");
      _;
   }

   function subscribe() public payable {
      require(msg.value == subscriptionFee, "Payment required.");

      if (subscriptionExpiry[msg.sender] == 0 || subscriptionExpiry[msg.sender] < block.timestamp) {
         subscriptionExpiry[msg.sender] = block.timestamp + recurringInterval;
      } else {
         subscriptionExpiry[msg.sender] += recurringInterval;
      }

      emit SubscriptionRenewed(msg.sender, subscriptionExpiry[msg.sender]);
   }

   function unsubscribe() public onlySubscriber {
      subscriptionExpiry[msg.sender] = 0;
   }

   function getSubscriptionExpiry(address subscriber) public view returns(uint) {
      return subscriptionExpiry[subscriber];
   }


}
