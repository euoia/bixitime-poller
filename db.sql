# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: 127.0.0.1 (MySQL 5.6.17)
# Database: bixi-bikes
# Generation Time: 2015-05-25 00:09:27 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table log
# ------------------------------------------------------------

DROP TABLE IF EXISTS `log`;

CREATE TABLE `log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `message` longtext,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `level` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table poll
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll`;

CREATE TABLE `poll` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `poll_date` timestamp NULL DEFAULT NULL,
  `last_update` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table station
# ------------------------------------------------------------

DROP TABLE IF EXISTS `station`;

CREATE TABLE `station` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `poll_date` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `terminal_name` varchar(255) DEFAULT NULL,
  `last_comm_with_server` datetime DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `long` float DEFAULT NULL,
  `installed` tinyint(1) DEFAULT NULL,
  `locked` tinyint(1) DEFAULT NULL,
  `install_date` datetime DEFAULT NULL,
  `removal_date` datetime DEFAULT NULL,
  `temporary` int(11) DEFAULT NULL,
  `public` tinyint(1) DEFAULT NULL,
  `bikes` int(11) DEFAULT NULL,
  `empty_docks` int(11) DEFAULT NULL,
  `total_docks` int(11) DEFAULT NULL,
  `latest_update_time` datetime DEFAULT NULL,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `station_data_upd` BEFORE UPDATE ON `station` FOR EACH ROW BEGIN
	IF
		new.name != old.name OR
		new.terminal_name != old.terminal_name OR
		new.lat != old.lat OR
		new.long != old.long OR
		new.installed != old.installed OR
		new.locked != old.locked OR
		new.install_date != old.install_date OR
		new.removal_date != old.removal_date OR
		new.temporary != old.temporary OR
		new.public != old.public OR
		new.total_docks != old.total_docks
	THEN
		INSERT INTO station_data_aud (
			station_id,
			poll_date,
			name_before,
			name_after,
			terminal_name_before,
			terminal_name_after,
			lat_before,
			lat_after,
			long_before,
			long_after,
			installed_before,
			installed_after,
			locked_before,
			locked_after,
			install_date_before,
			install_date_after,
			removal_date_before,
			removal_date_after,
			temporary_before,
			temporary_after,
			public_before,
			public_after,
			total_docks_before,
			total_docks_after
		)
		VALUES (
			new.id,
			new.poll_date,
			old.name,
			new.name,
			old.terminal_name,
			new.terminal_name,
			old.lat,
			new.lat,
			old.long,
			new.long,
			old.installed,
			new.installed,
			old.locked,
			new.locked,
			old.install_date,
			new.install_date,
			old.removal_date,
			new.removal_date,
			old.temporary,
			new.temporary,
			old.public,
			new.public,
			old.total_docks,
			new.total_docks
		);
	END IF;
	
	IF new.bikes != old.bikes OR new.empty_docks != old.empty_docks THEN
		INSERT INTO station_bikes_aud (station_id, poll_date, latest_update_time, bikes_before, empty_docks_before, bikes_after, empty_docks_after)
		VALUES (new.id, new.poll_date, new.latest_update_time, old.bikes, old.empty_docks, new.bikes, new.empty_docks);
	END IF;

END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table station_bikes_aud
# ------------------------------------------------------------

DROP TABLE IF EXISTS `station_bikes_aud`;

CREATE TABLE `station_bikes_aud` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `station_id` varchar(255) DEFAULT NULL,
  `poll_date` datetime DEFAULT NULL,
  `latest_update_time` timestamp NULL DEFAULT NULL,
  `bikes_before` int(11) DEFAULT NULL,
  `bikes_after` int(11) DEFAULT NULL,
  `empty_docks_before` int(11) DEFAULT NULL,
  `empty_docks_after` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table station_data_aud
# ------------------------------------------------------------

DROP TABLE IF EXISTS `station_data_aud`;

CREATE TABLE `station_data_aud` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `station_id` varchar(255) DEFAULT NULL,
  `poll_date` datetime DEFAULT NULL,
  `name_before` varchar(255) DEFAULT NULL,
  `name_after` varchar(255) DEFAULT NULL,
  `terminal_name_before` varchar(255) DEFAULT NULL,
  `terminal_name_after` varchar(255) DEFAULT NULL,
  `lat_before` float DEFAULT NULL,
  `lat_after` float DEFAULT NULL,
  `long_before` float DEFAULT NULL,
  `long_after` float DEFAULT NULL,
  `installed_before` tinyint(1) DEFAULT NULL,
  `installed_after` tinyint(1) DEFAULT NULL,
  `locked_before` tinyint(1) DEFAULT NULL,
  `locked_after` tinyint(1) DEFAULT NULL,
  `install_date_before` datetime DEFAULT NULL,
  `install_date_after` datetime DEFAULT NULL,
  `removal_date_before` datetime DEFAULT NULL,
  `removal_date_after` datetime DEFAULT NULL,
  `temporary_before` int(11) DEFAULT NULL,
  `temporary_after` int(11) DEFAULT NULL,
  `public_before` tinyint(1) DEFAULT NULL,
  `public_after` tinyint(1) DEFAULT NULL,
  `total_docks_before` int(11) DEFAULT NULL,
  `total_docks_after` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
