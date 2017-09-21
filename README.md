# NuBank Balances API

Start the api service `$ sudo docker-compose up -d api`. Install the project dependencies: `$ sudo docker-compose run api mix deps.get`, and to compile: `$ sudo docker-compose run api mix deps.compile`.

Creating the database: `$ sudo docker-compose run api mix ecto.create`. Run the migrations: `$ sudo docker-compose run api mix ecto.migrate`.

Restart the server: `$ sudo docker-compose restart api`.

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## API Docs

#### Check availability
This method check the API availability
```
GET /api/
```
###### Response
```
Status: 200 OK
```
```json
{
 "success": "Successfully connected"
}
```

#### Add operation on checking account
This method adds an operation to a given checking account identified by account number
```
POST /api/operations
```
###### Parameters
Name | Type | Description
------------ | ------------- | -------------
account | integer | The account number of checking account
type | string | The type of operation. It could be of two categories: putting (`deposit`, `salary`, `credit`) or taking (`purchase`, `withdrawal`, `debit`)
description | string | The description of operation. This attribute is optional
amount | decimal | The amount of operation. This value must be a non negative decimal
done_at | string | The date of operation in format YYYY-MM-DD

###### Response
```
Status: 201 Created
```
```json
{
 "success": "ok"
}
```

#### Get current balance
This method gets the current balance of a given account
```
GET /api/balance/:account
```

###### Response
```
Status: 200 OK
```
```json
{
 "balance": "771.43"
}
```

#### Get bank statement
This method gets the bank statement of a given account
```
POST /api/account/:account/statement
```
###### Query
Name | Type | Description
------------ | ------------- | -------------
start_at | string | The start date of statement period in format YYYY-MM-DD
end_at | string | The end date of statement period in format YYYY-MM-DD

###### Response
```
Request: /api/account/10/statement?start_at=2017-10-15&end_at=2017-10-17
Status: 200 OK
```
```json
[
 {
  "operations": [
   {"type": "deposit", "description": null, "amount": "1000"}
  ],
  "date": "15/10/2017",
  "balance": "1000"
 },
 {
  "operations": [
   {"type": "purchase", "description": null, "amount": "3.34"},
   {"type": "purchase", "description": null, "amount": "45.23"}
  ],
  "date": "16/10/2017",
  "balance": "951.43"
 },
 {
   "operations": [
   {"type": "withdrawal", "description": null, "amount": "180.0"}
  ],
  "date": "17/10/2017",
  "balance": "771.43"
 }
]
```

#### Get debt periods
This method gets debt periods of a given account
```
POST /api/account/:account/debt-periods
```

###### Response
```
Status: 200 OK
```
```json
[
 {
  "start_date": "18/10/2017",
  "principal": "28.57",
  "end_date": "21/10/2017"
 },
 {
  "start_date": "22/10/2017",
  "principal": "38.57",
  "end_date": "24/10/2017"
	}
]
```
