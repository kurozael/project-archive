-- phpMyAdmin SQL Dump
-- version 3.1.3.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 14, 2009 at 11:35 PM
-- Server version: 5.1.33
-- PHP Version: 5.2.9-2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `kuroscript`
--

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE IF NOT EXISTS `characters` (
  `_Key` int(11) NOT NULL AUTO_INCREMENT,
  `_Data` longtext NOT NULL,
  `_Name` longtext NOT NULL,
  `_Game` longtext NOT NULL,
  `_Ammo` longtext NOT NULL,
  `_Model` longtext NOT NULL,
  `_Class` longtext NOT NULL,
  `_Gender` longtext NOT NULL,
  `_Access` longtext NOT NULL,
  `_SteamID` longtext NOT NULL,
  `_Currency` longtext NOT NULL,
  `_Inventory` longtext NOT NULL,
  `_Attributes` longtext NOT NULL,
  `_CharacterID` longtext NOT NULL,
  `_SteamName` longtext NOT NULL,
  `_KnownNames` longtext NOT NULL,
  PRIMARY KEY (`_Key`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3951 ;

-- --------------------------------------------------------

--
-- Table structure for table `charlogs`
--

CREATE TABLE IF NOT EXISTS `charlogs` (
  `_Key` int(11) NOT NULL AUTO_INCREMENT,
  `_Text` longtext NOT NULL,
  `_Date` longtext NOT NULL,
  `_Time` longtext NOT NULL,
  `_Game` longtext NOT NULL,
  `_Table` longtext NOT NULL,
  `_SteamID` longtext NOT NULL,
  `_CharacterKey` longtext NOT NULL,
  PRIMARY KEY (`_Key`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2579 ;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `_Key` int(11) NOT NULL AUTO_INCREMENT,
  `_Data` longtext NOT NULL,
  `_Game` longtext NOT NULL,
  `_SteamID` longtext NOT NULL,
  `_IPAddress` longtext NOT NULL,
  `_SteamName` longtext NOT NULL,
  PRIMARY KEY (`_Key`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2238 ;
