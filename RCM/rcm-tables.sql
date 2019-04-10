--
--
--

CREATE TABLE IF NOT EXISTS rcm_raw_plans (
	ID varchar(32) NOT NULL default '',
	NAME varchar(64) NOT NULL default '',
  	INFO varchar(255) NOT NULL default '',
  	AUTHOR varchar(64) NOT NULL default '',
  	PRICE varchar(8) NOT NULL default '',
  	ISSUE varchar(32) NOT NULL default '',
  	CATEGORY varchar(10) NOT NULL default '',
  	FILE varchar(32) NOT NULL default '',
  	NOTE varchar(255) NOT NULL default '',
  	IMAGE varchar(32) NOT NULL default '',
  	PRIMARY KEY  (ID)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS rcm_ext_plans (
	ID varchar(32) NOT NULL default '',
	CATEGORY_SET INT NOT NULL,

	E_LOW DECIMAL(6,3) NOT NULL default '0.000', --
	E_UP DECIMAL(6,3) NOT NULL default '0.000',
	E4_LOW DECIMAL(6,3) NOT NULL default '0.000',
	E4_UP DECIMAL(6,3) NOT NULL default '0.000',

	SPAN_BOT DECIMAL(10,2) NOT NULL default '0.00',
	SPAN_TOP DECIMAL(10,2) NOT NULL default '0.00',

	PRIMARY KEY  (ID)
);

CREATE TABLE IF NOT EXISTS rcm_cats (
	cat_id integer NOT NULL, -- must be power of 2 (1, 2, 4, 8, ...)
	d_short varchar(32) NOT NULL, -- short description
	d_long varchar(255) NOT NULL, -- long descrription
	PRIMARY KEY(cat_id)
);

--
--
--

INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(1, 'Aerobatic', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(2, 'Multi-Wing', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(4, 'Handlaunch', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(8, 'Jet', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(16, 'Pod & Boom', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(32, 'Multi-Engine', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(64, 'Sailplane', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(128, 'Scale', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(256, 'Seaplane', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(512, 'Slope', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(1024, 'Speed', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(2048, 'Thermal. Dur.', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(4096, 'Trainer', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(8192, 'Unique or Vintage', '');
INSERT INTO rcm_cats (cat_id,d_short,d_long) VALUES(16384, 'Warbird', '');
