// Adapted from: https://github.com/fsainas/contracts-verification-benchmark/tree/main/contracts/vault

contract Vault {
    address owner;
    address recovery;
    uint wait_time;

    address receiver;
    int request_time;
    int amount;
    int state;
    // 0 = IDLE
    // 1 = REQ
   
    constructor (address recovery_, int wait_time_) payable {
    	require(msg.sender != recovery_);
      require(wait_time_ >= 0);
        owner = msg.sender;
        recovery = recovery_;
        wait_time = wait_time_;
        state = 0 // IDLE
    }

    function withdraw(address receiver_, int amount_) {
        require(state == 0); // IDLE
        require(amount_ <= balance);
        require(msg.sender == owner);

        request_time = block.number;
        amount = amount_;
        receiver = receiver_;
        state = 1 // REQ
    }

    function finalize() {
        require(state == 1); // REQ
        require(block.number >= request_time + wait_time);
        require(msg.sender == owner);

        state = 0; // IDLE	
        receiver.transfer(amount)
    }

    function cancel() {
        require(state == 1); // REQ
        require(msg.sender == recovery);
        state = 0 // IDLE
    }
}

// valid (k=1)
// @groundtruth: True
rule Two_steps_drainability {
    (state == 0) ->
    (exists addr: address .
    exists recipient: address .
    exists f1: method .
    exists args1: calldataargs .
    exists msgvalue1 : int .
    exists f2: method .
    exists args2: calldataargs .
    exists msgvalue2 : int .
    (<< addr : Vault . f1(args1) $ msgvalue1 >>		
        << addr : Vault . f2(args2) $ msgvalue2 >>		
              (balance[recipient] ==  old(old(balance[recipient] +balance)))
    ))
}

// @groundtruth: True
rule Two_steps_drainability_non_inflation {
    (state == 0 && wait_time > 0) ->
    (exists addr: address .
    exists recipient: address .
    exists f1: method .
    exists args1: calldataargs .
    exists msgvalue1 : int .
    exists f2: method .
    exists args2: calldataargs .
    exists msgvalue2 : int .
    (<< addr : Vault . f1(args1) $ msgvalue1 >>		
         block.number == old(block.number)
         &&
        << addr : Vault . f2(args2) $ msgvalue2 >>		
          forall addr3 : address .
              (balance[addr3] ==  old(old(balance[addr3])))
    ))
}

