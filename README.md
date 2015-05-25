bixitime-poller
===============

This application polls the Montreal Bixi XML API and stores the results in a
database.

Installation
------------

Load the database schema:

```
mysql -u root -p -e 'CREATE DATABASE `bixitime`'
mysql -u root -p bixitime < db.sql
```

Install node dependencies:

```
npm install
```

Configure the application:

```
cp config.sample.json config.json
```

Modify `config.json` with your database settings.

Run the application:

```
npm start
```
