// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract freelance{
    uint256 public amount;
    address public owner; //Service address
    address public customer;
    address public executor;
    uint256 public dateDeadline;
    uint256 public dateAcceptWork;
    uint256 public commission;

    enum CONTRACT_STATE {
      CREATED,
      WORK,
      COMPLITE_EXECUTOR,
      COMPLITE_CUSTOMER,
      CANCEL_CUSTOMER,
      CANCEL_EXECUTOR,
      END,
      CONFLICT
    }
    CONTRACT_STATE public contract_state;

    constructor(uint256 _amount, address _customer, address _executor, uint256 _dateDeadline, uint256 _dateAcceptWork){
        owner = 0x429a41Bf637Ae722380663730F3854Cc96F548D4;
        commission = _amount * 1 / 100;
        amount = _amount;
        customer = _customer;
        executor = _executor;
        dateDeadline = _dateDeadline;
        dateAcceptWork = _dateAcceptWork;
    }

    modifier onlyOwner {
    	//is the message sender owner of the contract?
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyCustomer{
      require(msg.sender == customer);
        _;
    }

    modifier onlyExecutor{
      require(msg.sender == executor);
        _;
    }

    function balanceview() public view returns(uint256){
        uint256 balance = address(this).balance;
        return balance;
    }

    function fund() public onlyCustomer payable{
        require(msg.value == amount, "You need to spend true amount ETH!");
        require(contract_state == CONTRACT_STATE.CREATED);
        contract_state = CONTRACT_STATE.WORK;
    }

    function compliteExecutor() public onlyExecutor{
        require(contract_state == CONTRACT_STATE.WORK);

        require(block.timestamp <= dateDeadline);
        contract_state = CONTRACT_STATE.COMPLITE_EXECUTOR;
    }

    function compliteCustomer() public onlyCustomer{
        require(contract_state == CONTRACT_STATE.COMPLITE_EXECUTOR);

        require(block.timestamp <= dateAcceptWork);
        contract_state = CONTRACT_STATE.COMPLITE_CUSTOMER;
    }

    function openConflict() public onlyCustomer{
        require(contract_state == CONTRACT_STATE.COMPLITE_EXECUTOR);

        require(block.timestamp <= dateAcceptWork);
        contract_state = CONTRACT_STATE.CONFLICT;
    }

    function cancelCustomer() public onlyCustomer{
        require(contract_state == CONTRACT_STATE.WORK);

        require(block.timestamp > dateDeadline);
        contract_state = CONTRACT_STATE.CANCEL_CUSTOMER;
    }

    function cancelBeforeDeadlineExecutor() public onlyExecutor{
      require(contract_state == CONTRACT_STATE.WORK);

      require(block.timestamp <= dateDeadline);
      contract_state = CONTRACT_STATE.CANCEL_CUSTOMER;
    }

    function cancelExecutor() public onlyExecutor{
        require(contract_state == CONTRACT_STATE.COMPLITE_EXECUTOR);

        require(block.timestamp > dateAcceptWork);
        contract_state = CONTRACT_STATE.CANCEL_EXECUTOR;
    }

    function cancelAfterCompliteExecutor() public onlyExecutor{
        require(contract_state == CONTRACT_STATE.COMPLITE_EXECUTOR);

        require(block.timestamp <= dateAcceptWork);
        contract_state = CONTRACT_STATE.CANCEL_CUSTOMER;
    }

    function increaseWork(uint256 _increaseDateDeadline) public onlyCustomer{
        require(contract_state == CONTRACT_STATE.WORK);
        if(dateDeadline >= block.timestamp){
            dateDeadline = dateDeadline + _increaseDateDeadline;
        }
        else{
            dateDeadline = block.timestamp + _increaseDateDeadline;
        }
    }

    function increaseAcceptWork(uint256 _increaseDateAcceptWork) public onlyExecutor{
        require(contract_state == CONTRACT_STATE.COMPLITE_EXECUTOR);
        if(dateAcceptWork >= block.timestamp){
            dateAcceptWork = dateAcceptWork + _increaseDateAcceptWork;
        }
        else{
            dateAcceptWork = block.timestamp + _increaseDateAcceptWork;
        }
    }

    function withdrawlCustomer() public onlyCustomer{
        require(address(this).balance > commission, "Not enough funds!");
        require(contract_state == CONTRACT_STATE.CANCEL_CUSTOMER);
        payable(owner).transfer(commission);
        payable(msg.sender).transfer(address(this).balance);
        contract_state = CONTRACT_STATE.END;
    }

    function withdrawlExecutor() public onlyExecutor{
        require(address(this).balance > commission, "Not enough funds!");
        require(contract_state == CONTRACT_STATE.COMPLITE_CUSTOMER || contract_state == CONTRACT_STATE.CANCEL_EXECUTOR);
        payable(owner).transfer(commission);
        payable(msg.sender).transfer(address(this).balance);
        contract_state = CONTRACT_STATE.END;
    }

    function changeStateToCREATED() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.CREATED;
    }

    function changeStateToWORK() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.WORK;
    }

    function changeStateToCOMPLITE_EXECUTOR() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.COMPLITE_EXECUTOR;
    }

    function changeStateToCOMPLITE_CUSTOMER() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.COMPLITE_CUSTOMER;
    }

    function changeStateToCANCEL_CUSTOMER() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.CANCEL_CUSTOMER;
    }

    function changeStateToCANCEL_EXECUTOR() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.CANCEL_EXECUTOR;
    }

    function changeStateToEND() public onlyOwner{
        require(contract_state == CONTRACT_STATE.CONFLICT);
        contract_state = CONTRACT_STATE.END;
    }

}
