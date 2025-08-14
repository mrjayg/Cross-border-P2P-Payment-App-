module MyModule::CrossBorderPayment {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;

    /// Struct representing a user's payment account
    struct PaymentAccount has store, key {
        balance: u64,           // User's available balance
        total_sent: u64,        // Total amount sent by user
        total_received: u64,    // Total amount received by user
    }

    #[event]
    /// Event emitted when a payment is made
    struct PaymentEvent has drop, store {
        sender: address,
        receiver: address,
        amount: u64,
    }

    /// Function to initialize a payment account for cross-border transactions
    public fun create_payment_account(user: &signer) {
        let account = PaymentAccount {
            balance: 0,
            total_sent: 0,
            total_received: 0,
        };
        move_to(user, account);
    }

    /// Function to send cross-border payment to another user
    public fun send_payment(
        sender: &signer, 
        receiver_address: address, 
        amount: u64
    ) acquires PaymentAccount {
        let sender_address = signer::address_of(sender);
        
        // Transfer coins from sender to receiver
        let payment = coin::withdraw<AptosCoin>(sender, amount);
        coin::deposit<AptosCoin>(receiver_address, payment);
        
        // Update sender's account
        let sender_account = borrow_global_mut<PaymentAccount>(sender_address);
        sender_account.total_sent = sender_account.total_sent + amount;
        
        // Update receiver's account
        let receiver_account = borrow_global_mut<PaymentAccount>(receiver_address);
        receiver_account.total_received = receiver_account.total_received + amount;
        
        // Emit payment event
        event::emit(PaymentEvent {
            sender: sender_address,
            receiver: receiver_address,
            amount,
        });
    }
}
