## ExBanking
### Test task for Elixir developers: This project is a simple banking OTP application written in Elixir.

### General Information
 ExBanking is an OTP application that provides basic banking operations such as creating users, depositing money, withdrawing money, checking balances, and transferring money between users.

 ### Public functions
 #### Create User
Creates a new user in the system. New users start with a zero balance.

#### Deposit
Increases the user’s balance in the specified currency by the given amount. Returns the new balance.

#### Withdraw
Decreases the user’s balance in the specified currency by the given amount. Returns the new balance.

#### Get balance
Returns the balance of the user in the specified currency.

#### Send
Transfers the specified amount from one user to another. Returns the balance of both users.

### Performance

* The system should handle up to 10 operations per user at any given time.
* If there are more than 10 pending operations for a user, new operations should return :too_many_requests_to_user error.
* The system should handle requests for different users simultaneously.
* Requests for one user should not affect the performance of requests for another user, except for the send function involving both users.

### Getting started

```bash
git clone https://github.com/OlegGorod/ex_banking_gorodenskyi
cd ex_banking
mix deps.get
iex -S mix
```

### Running Tests
To run the tests:
```bash
mix test
```

