-- MySQL dump 10.13  Distrib 5.7.22, for osx10.13 (x86_64)
--
-- ------------------------------------------------------
-- Server version	5.6.27-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `data`
--

DROP TABLE IF EXISTS `data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data` (
  `runnum` int(11) NOT NULL,	      -- Identify which run this row is from
  `rep` int(11) NOT NULL DEFAULT '0', -- Identify which repetition this row is from
  `x` int(11) NOT NULL DEFAULT '0',   -- independent variable. varies with test
  `y` int(11) DEFAULT NULL,	      -- dependent variable
  PRIMARY KEY (`runnum`,`rep`,`x`),   -- Form a primary key based on first three columns
  CONSTRAINT `data_ibfk_1` FOREIGN KEY (`runnum`) REFERENCES `metadata` (`runnum`) -- column runnum is a foriegn key for metadata
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `memdata`
--

DROP TABLE IF EXISTS `memdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memdata` (
  `runnum` int(11) NOT NULL DEFAULT '0', -- Identify which run this row is from
  `rep` int(11) NOT NULL DEFAULT '0',	 -- Identify which repetition this row is from
  `operation` varchar(20) NOT NULL DEFAULT '', -- Operation performed
  `hostname` varchar(20) NOT NULL DEFAULT '',  -- Host which reported this row
  `nodes` int(11) NOT NULL DEFAULT '0',	       -- Number of nodes run across
  `ppn` int(11) NOT NULL DEFAULT '0',	       -- Number of processes per node
  `usage_daemon` double DEFAULT NULL,	       -- Memory usage of the daemon
  `usage_client` double DEFAULT NULL,	       -- Memory usage of the client
  `command` text,			       -- Command which was run
  PRIMARY KEY (`runnum`,`rep`,`operation`,`hostname`,`nodes`,`ppn`), -- Form a primary key based on the first six columns
  CONSTRAINT `memdata_ibfk_1` FOREIGN KEY (`runnum`) REFERENCES `metadata` (`runnum`) -- column runnum is a foreign key for metadata
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metadata` (
  `runnum` int(11) NOT NULL AUTO_INCREMENT, -- Unique identifier of this test run
  `hash` varchar(255) DEFAULT NULL,	    -- Git hash of the current ompi build
  `branch` varchar(255) DEFAULT NULL,	    -- Git branch ompi was built from
  `nproc` int(11) DEFAULT NULL,		    -- Number of processors per node
  `testname` varchar(255) DEFAULT NULL,	    -- Name of test which was run
  `rundate` datetime DEFAULT NULL,	    -- Date test was run
  PRIMARY KEY (`runnum`)		    -- Set runnum to be the primary key (enforces uniqueness)
) ENGINE=InnoDB AUTO_INCREMENT=234 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-06-07 14:18:30
