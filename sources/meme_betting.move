module meme_betting::Betting {
    use std::signer;
    use std::string;
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    use aptos_framework::table;

    /// Contract owner (deployer address)
    const CONTRACT_OWNER: address = @0x2ef8c64ad94d541b77fbdfcb96b15370450907daad55356fb9c59ff96c929d30;

    /// Struct representing a single bet
    struct Bet has copy, drop, store {
        user: address, 
        meme_id: string, 
        amount: u64, 
        prediction: bool // true = viral, false = not viral
    }

    /// Struct representing a betting pool for a meme
    struct MemePool has copy, drop, store { 
        meme_id: string, 
        total_amount: u64, 
        viral_pool: u64, 
        not_viral_pool: u64, 
        bets: vector<Bet>, 
        created_at: u64, 
        completed: bool
    }

    /// Storage resource for meme betting pools
    struct BettingData has key {
        pools: table::Table<string, MemePool, string>
    }

    /// Event to emit when winners are paid out
    struct WinnerPaymentEvent has key, store {
        meme_id: string,
        total_payout: u64
    }

    /// ** Contract Initialization (Should be called by the deployer)**
    public entry fun initialize(owner: &signer) acquires BettingData {
        let betting_data = BettingData { pools: table::new<string, MemePool, string>(signer::address_of(owner)) };
        move_to(owner, betting_data);
    }

    /// ** Place a bet on a meme**
    public entry fun place_bet(
        sender: &signer, 
        meme_id: string, 
        amount: u64, 
        prediction: bool
    ) acquires BettingData {
        let user = signer::address_of(sender);
        let betting_data = borrow_global_mut<BettingData>(CONTRACT_OWNER);

        // Transfer the bet amount from user to contract owner (escrow)
        coin::transfer(sender, CONTRACT_OWNER, amount);

        // If meme pool does not exist, create one
        if (!table::contains(&betting_data.pools, &meme_id)) {
            let new_pool = MemePool { 
                meme_id: meme_id.clone(), 
                total_amount: 0, 
                viral_pool: 0, 
                not_viral_pool: 0, 
                bets: vector::empty<Bet>(), 
                created_at: timestamp::now_seconds(), 
                completed: false
            };
            table::add(&mut betting_data.pools, meme_id.clone(), new_pool);
        }

        // Get the meme pool and update it with the new bet
        let pool_ref = table::borrow_mut(&mut betting_data.pools, &meme_id);
        assert!(!pool_ref.completed, 1); // Ensure betting is still open
        pool_ref.total_amount = pool_ref.total_amount + amount;
        
        if (prediction) {
            pool_ref.viral_pool = pool_ref.viral_pool + amount;
        } else {
            pool_ref.not_viral_pool = pool_ref.not_viral_pool + amount;
        }

        vector::push_back(&mut pool_ref.bets, Bet { user, meme_id, amount, prediction });
    }

    /// ** Distribute rewards after 7 days**
    public entry fun distribute_rewards(
        admin: &signer, 
        meme_id: string, 
        is_viral: bool,
        creator: address
    ) acquires BettingData {
        let admin_address = signer::address_of(admin);
        assert!(admin_address == CONTRACT_OWNER, 2); // Only deployer can distribute rewards

        let betting_data = borrow_global_mut<BettingData>(CONTRACT_OWNER);
        let pool_ref = table::borrow_mut(&mut betting_data.pools, &meme_id);

        // Ensure 7 days have passed before distributing rewards
        let current_time = timestamp::now_seconds();
        assert!(current_time >= pool_ref.created_at + (7 * 24 * 60 * 60), 3); // 7 days in seconds
        assert!(!pool_ref.completed, 4); // Ensure rewards are not already distributed

        let winning_pool = if (is_viral) { pool_ref.viral_pool } else { pool_ref.not_viral_pool };
        let losing_pool = pool_ref.total_amount - winning_pool;
        let platform_fee = losing_pool / 10; // 10% platform fee
        let reward_pool = losing_pool - platform_fee;

        // Transfer 30% of platform fee to meme creator
        coin::transfer(CONTRACT_OWNER, creator, (platform_fee * 3) / 10);

        // Distribute rewards to winners
        for bet in &pool_ref.bets {
            if (bet.prediction == is_viral) {
                let payout = (bet.amount * reward_pool) / winning_pool;
                coin::transfer(CONTRACT_OWNER, bet.user, payout + bet.amount);
            }
        }

        // Mark as completed
        pool_ref.completed = true;

        // Emit event
        event::emit<WinnerPaymentEvent>(&WinnerPaymentEvent { meme_id, total_payout: reward_pool });
    }
}
