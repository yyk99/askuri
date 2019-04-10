-- MySQL dump 8.22
--
-- Host: localhost    Database: rcm
---------------------------------------------------------
-- Server version	3.23.51

--
-- Table structure for table 'rcmplans'
--

CREATE TABLE rcmplans (
  plan_id varchar(10) NOT NULL default '',
  info text NOT NULL,
  author varchar(255) NOT NULL default '',
  issue varchar(255) NOT NULL default '',
  title varchar(255) NOT NULL default '',
  category varchar(255) NOT NULL default '',
  price decimal(10,2) NOT NULL default '0.00',
  img varchar(255) NOT NULL default '',
  img_width int(11) NOT NULL default '0',
  img_height int(11) NOT NULL default '0',
  low_displ decimal(5,2) NOT NULL default '0.00',
  up_displ decimal(5,2) NOT NULL default '0.00',
  type enum('upwing','lowwing','bipe','other') NOT NULL default 'other',
  PRIMARY KEY  (plan_id)
) TYPE=MyISAM;

