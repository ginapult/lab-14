-- -- Steps

-- 1. DATABASE SET UP --
CREATE DATABASE lab14
-- in psql shell, creates a lab14 database, after \q to get back to terminal
psql -f data/schema.sql -d lab14
-- in terminal, uses schema.sql create and populate the "books" table
-- restart psql, \c lab14 to connect to database
SELECT COUNT(*) FROM books;
-- verifies that books table has expected content
CREATE DATABASE lab14_normal WITH TEMPLATE lab14;
-- creates a copy of the lab14 database with name lab14_normal
\c lab14_normal
-- connects to lab14_normal database
SELECT COUNT * FROM books
-- should see same content as lab14 because it's a copy

-- 2. DATABASE MIGRATION --
CREATE TABLE BOOKSHELVES (id SERIAL PRIMARY KEY, name VARCHAR(255));
-- creates a second table in the lab14_normal database named bookshelves
\d bookshelves
-- confirms success
INSERT INTO bookshelves(name) SELECT DISTINCT bookshelf FROM books;
-- retrieves unique bookshelf values from books table and inserts each one into the bookshelves table in the name column
SELECT COUNT * FROM bookshelves
-- confirms success, number greater than zero
ALTER TABLE books ADD COLUMN bookshelf_id INT;
-- adds a column to the books table called bookshelf_id, connects each book to specific bookshelf in the bookshelves table
\d books
-- confirms the success, table schema should include the new column and a column for the string bookshelf
UPDATE books SET bookshelf_id=shelf.id FROM (SELECT * FROM bookshelves) AS shelf WHERE books.bookshelf = shelf.name;
-- prepares a connection between the two tables, runs a subquery for every row in books table, finding bookshelf row with name matching the current book's bookshelf value, id of that bookshelf row set as the value of the bookshelf_id property in the current book row
SELECT bookshelf_id FROM books
-- this confirm success, displays column containing unique ids for the bookshelves - numbers should match total number confirmed when we confirmed the success of insertion of names into the bookshelves table
ALTER TABLE books DROP COLUMN bookshelf;
-- this will modify the books table by removing the column named bookshelf; the books table now contains a bookshelf_id which will become the foreign key
\d books
-- the books table schema displays without the bookshelf column
ALTER TABLE books ADD CONSTRAINT fk_bookshelves FOREIGN KEY (bookshelf_id) REFERENCES bookshelves(id);
-- modifies data type of bookshelf_id in the books table, setting it as a foreign key which references the primary key in the bookshelves table
\d books
-- see details about the foreign key constraints - confirms success

-- 3. ADDITION OF A MIGRATIONS FOLDER --
-- create a /data folder in root of repo; create folder called "migrations"
-- migrations will contain a series of files that represent a changelog of db configuration
-- convention for naming follows the pattern of timestamp-descrption.sql (like this file)
-- files contains the SQL queries executed in order with comments to descripe the purpose of each query
-- obtain date stamp by opening browser developer tools (inspector) typing "Date.now()" to get the timestamp
-- copy time stamp and use it to name the file with the description
-- NOTE: naming convention ensures team keeps track of how and when the database is changing over the life of the project