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

CREATE TABLE IF NOT EXISTS `players` (
  `_Key` smallint(11) unsigned NOT NULL AUTO_INCREMENT,
  `_Data` text NOT NULL,
  `_Schema` text NOT NULL,
  `_SteamID` varchar(60) NOT NULL,
  `_Donations` text NOT NULL,
  `_UserGroup` text NOT NULL,
  `_IPAddress` varchar(50) NOT NULL,
  `_SteamName` varchar(150) NOT NULL,
  `_OnNextPlay` text NOT NULL,
  `_LastPlayed` varchar(50) NOT NULL,
  `_TimeJoined` varchar(50) NOT NULL,
  PRIMARY KEY (`_Key`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;