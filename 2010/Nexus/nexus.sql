-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 29, 2010 at 09:32 PM
-- Server version: 5.1.45
-- PHP Version: 5.2.9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `nexus`
--

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE IF NOT EXISTS `characters` (
  `_Key` smallint(11) unsigned NOT NULL AUTO_INCREMENT,
  `_Data` text NOT NULL,
  `_Name` varchar(150) NOT NULL,
  `_Ammo` text NOT NULL,
  `_Cash` varchar(150) NOT NULL,
  `_Model` varchar(250) NOT NULL,
  `_Flags` text NOT NULL,
  `_Schema` text NOT NULL,
  `_Gender` varchar(50) NOT NULL,
  `_Faction` varchar(50) NOT NULL,
  `_SteamID` varchar(60) NOT NULL,
  `_SteamName` varchar(150) NOT NULL,
  `_Inventory` text NOT NULL,
  `_OnNextLoad` text NOT NULL,
  `_Attributes` text NOT NULL,
  `_LastPlayed` varchar(50) NOT NULL,
  `_TimeCreated` varchar(50) NOT NULL,
  `_CharacterID` varchar(50) NOT NULL,
  `_RecognisedNames` text NOT NULL,
  PRIMARY KEY (`_Key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;


-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `_Key` smallint(11) unsigned NOT NULL AUTO_INCREMENT,
  `_Data` text NOT NULL,
  `_Schema` text NOT NULL,
  `_SteamID` varchar(60) NOT NULL,
  `_IPAddress` varchar(50) NOT NULL,
  `_SteamName` varchar(150) NOT NULL,
  `_OnNextPlay` text NOT NULL,
  `_LastPlayed` varchar(50) NOT NULL,
  `_TimeJoined` varchar(50) NOT NULL,
  PRIMARY KEY (`_Key`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;