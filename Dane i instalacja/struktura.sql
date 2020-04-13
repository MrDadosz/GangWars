
CREATE TABLE `dadosz_gangwars` (
  `area_index` smallint(3) UNSIGNED NOT NULL,
  `gang_owning_color` enum('gray','purple','green','orange','yellow','white','pink','blue','nobody') NOT NULL,
  `take_over_time` datetime NOT NULL DEFAULT '2000-01-01 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `lss_co` ADD `last_attack` datetime NOT NULL AFTER `name`;
ALTER TABLE `lss_co` ADD `today_attacks` tinyint(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `last_attack`;
ALTER TABLE `lss_co` ADD `color` enum('gray','purple','green','orange','yellow','white','pink','blue','nobody') NOT NULL AFTER `today_attacks`;
ALTER TABLE `lss_co` ADD `container` int(10) UNSIGNED NOT NULL AFTER `color`;
