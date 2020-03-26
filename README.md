# Simple SQL Sample Example

A sample database with a set of simple query tasks to complete intended to help learn SQL from scratch. Includes database initialisation file (set_up_datbase.sql) and a set of example queries (example_queries.sql). Database is designed to mimic the typical form of data that would be encountered in the financial department of a business.


## Initial Setup:

Run the initialisation file set_up_database.sql. If you need help, there is a useful guide to setting up SQL avaliable [here](https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server?view=sql-server-ver15 "Guide to setting up SQL")<sup>1</sup>. This will build and populate a database of people and their personal details including name, D.O.B, bank etc. Don't worry about the code in this file too much, but you can read it if you feel like it.

Next, look through the example queries in example_queries.sql to see some examples and how they may be joined together.


## Query Tasks:

The following questions may be answered by writing queries to the database. Try to answer them *without* looking at the set up file.


### Part 1:

1. What is the average balance in each portfolio?
2. What is the average balance by ProductType?
3. What is the average balance today (discount previous collections from purchase value) of all customers whose surname begins with a G?
4. Which customer has the highest number of accounts?

### Part 2:
Without looking at the set up file, answer the following questions:

5. Which portfolio are people most likely to pay in?
6. Which product type are people most likely to pay in?
7. What is the pay rate over the last 12 months? That is, the number of customers who have paid in the last 12 months divided by the number of customers who had not cleared their balance in the last 12 months.

### Part 3 (Extra):
Again without looking at the initialisation file, can you build a model to determine the expected collections of an AccountId based on the information in the database.


### Acknowledgements
Thanks to [Paul Russell](https://github.com/pt-russell "Paul Russell Github") for providing the initialisation code, questions and general advice.


<sup>1</sup> Written for Windows machines but contains links to guides for other operating systems.
