var
	Bluebird = require('bluebird'),
	_ = require('lodash'),
	mysql = require('mysql'),
	config = require('./config.json'),
	logging = require('bixitime-lib-logging'),
	log = require('winston');

Bluebird.promisifyAll(mysql);
var parseString = Bluebird.promisify(require('xml2js').parseString);
var request = Bluebird.promisify(require('request'));

var apiUrl = 'https://montreal.bixi.com/data/bikeStations.xml';
var checkIntervalSeconds = 60;

var connection = mysql.createConnection(config.database);
logging.configureWinston(connection, config.logging.level);

function check() {
	request(apiUrl).spread(function (response, body) {
		log.debug('Got response:', body);
		return parseString(body);
	}).then(function (body) {

		var toDate = function (date) {
			var intDate = parseInt(date, 10);
			if (isNaN(intDate)) {
				return null;
			}

			return new Date(intDate);
		};

		var toBool = function (bool) {
			switch (bool) {
				case 'true':
					return 1;
				case 'false':
					return 0;
				default:
					return null;
			}
		};

		var lastUpdate = toDate(body.stations['$'].lastUpdate);
		var pollDate = new Date();

		/**
		 * Sorting by latestUpdateTime makes the audit table insert order more
		 * natural.
		 */
		var stations = _.chain(body.stations.station)
			.map(function (station) {
				var newStation = {
					id: station.id[0],
					name: station.name[0],
					terminalName: station.terminalName[0],
					lastCommWithServer: null,
					lat: station.lat[0],
					long: station.long[0],
					installed: toBool(station.installed[0]),
					locked: toBool(station.locked[0]),
					installDate: toDate(station.installDate[0]),
					removalDate: toDate(station.removalDate[0]),
					temporary: toBool(station.temporary[0]),
					public: toBool(station.public[0]),
					bikes: parseInt(station.nbBikes[0], 10),
					emptyDocks: parseInt(station.nbEmptyDocks[0]),
					latestUpdateTime: null,
				};

				newStation.totalDocks = newStation.bikes + newStation.emptyDocks;

				return newStation;
			})
			.sortBy('latestUpdateTime')
			.value();

		var queries = _.chain(stations)
			.map(function (station) {
				var stationQuery = connection.query(`
					INSERT INTO station
						(
							id, poll_date, name, terminal_name, last_comm_with_server, lat, \`long\`,
							installed, locked, install_date, removal_date, temporary,
							public, bikes, empty_docks, total_docks, latest_update_time
						)
						VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
						ON DUPLICATE KEY UPDATE
							poll_date=VALUES(poll_date),
							name=VALUES(name),
							terminal_name=VALUES(terminal_name),
							last_comm_with_server=VALUES(last_comm_with_server),
							lat=VALUES(lat),
							\`long\`=VALUES(\`long\`),
							installed=VALUES(installed),
							locked=VALUES(locked),
							install_date=VALUES(install_date),
							removal_date=VALUES(removal_date),
							temporary=VALUES(temporary),
							public=VALUES(public),
							bikes=VALUES(bikes),
							empty_docks=VALUES(empty_docks),
							total_docks=VALUES(total_docks),
							latest_update_time=VALUES(latest_update_time)
					`,
					[
						station.id,
						pollDate,
						station.name,
						station.terminalName,
						station.lastCommWithServer,
						station.lat,
						station.long,
						station.installed,
						station.locked,
						station.installDate,
						station.removalDate,
						station.temporary,
						station.public,
						station.bikes,
						station.emptyDocks,
						station.totalDocks,
						station.latestUpdateTime
					]
				);

				return [stationQuery];
			})
			.flatten()
			.value();

		queries.push(
			connection.query(`
				INSERT INTO poll
					(poll_date, last_update)
				VALUES
					(?, ?)
				`,
				[
					pollDate,
					lastUpdate
				]
			)
		);

		Bluebird.all(queries).then(function () {
			log.info(`Inserted data for ${stations.length} stations.`);
		});
	})
	.catch(function (err) {
		log.error('Got an error from the API: ' + err.message);
		log.error(err.stack);
	});
}

connection.connect();
check();
setInterval(check, checkIntervalSeconds * 1000);

process.on('SIGINT', function() {
	console.log('Caught SIGINT');
	connection.end();
	process.exit(1);
});
