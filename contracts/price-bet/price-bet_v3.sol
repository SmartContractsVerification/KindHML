contract Bet {

    bool player_has_joined;
    address owner;
    address oracle;
    address player;
    int rate;
    bool player_won

    constructor(address oracle_addr, int initial_rate) payable {
        require(oracle_addr != this);
        owner = msg.sender;
        oracle = oracle_addr; 
        rate = initial_rate;
        player_has_joined = false;
        player_won = false
    }

    function join() payable {
        require (balance == 2 * msg.value && !player_has_joined) ;
        player = msg.sender ;
        player_has_joined = true 
    }
    function win() {
        require(player_won);
        player.transfer(balance) 
    }
    function set() {
        require (msg.sender == oracle) ;
        player_won = true
    }
}


// @groundtruth: False
rule Running_example1 {
    (rate > 100 && player_has_joined)
    -> 
    exists a : address .
    exists f : method .
    exists args : calldataargs .    
    exists msgvalue : int .    
    << a : Bet . f(args) $ msgvalue >>
        balance[a] == old(balance[a] + balance)		
}


// @groundtruth: True
rule Running_example2 {
    player_has_joined
    ->
    exists a1 : address .
    exists a2 : address .
    exists f1 : method .
    exists f2 : method .
    exists args1 : calldataargs .
    exists args2 : calldataargs .
    << a1 : Pricebet . f1(args1) $ 0 >>		
        << a2 : Pricebet . f2(args2) $ 0 >>		
            (balance == 0)
}

// @groundtruth: False
rule Running_example3_Frontrun_simple {
    (player_won)
    ->
    (
    forall a : address .
    exists b : address .
    exists f : method .
    exists args : calldataargs .
    << b : Pricebet . f(args) $ 0 >>		
        << a : Pricebet . win() $ 0 >>
            lastReverted
    )
}
