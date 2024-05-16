CREATE DATABASE IF NOT EXISTS  video_record;
CREATE TABLE IF NOT EXISTS `video_record`.`record_data`(
  `record_id` varchar(32) NOT NULL,
  `group_id` varchar(64) CHARACTER SET utf8 NULL,
  `app_id` varchar(64) NULL,
  `start_time` varchar(64) NULL,
  `stop_time` varchar(64) NULL,
  `state` int(2) DEFAULT -1,
  `record_mode`  int(2) NULL,
  `file_name`  varchar(255) CHARACTER SET utf8 NULL, 
  `file_suffix`  varchar(255) NULL,
  `file_size`  bigint DEFAULT 0,
  `init_msg` varchar(1024) CHARACTER SET utf8 NULL, 
  `record_time`  bigint DEFAULT 0,
  PRIMARY KEY (`record_id`)
);
ALTER TABLE `video_record`.`record_data` DEFAULT  CHARSET=utf8mb4;
ALTER TABLE `video_record`.`record_data` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE `video_record`.`record_data` ADD `is_sub` int(2) DEFAULT 0 NOT NULL;
ALTER TABLE `video_record`.`record_data` ADD `main_record_id` varchar(32) NULL;
ALTER TABLE `video_record`.`record_data` ADD `media_topic` varchar(32) NULL;
ALTER TABLE `video_record`.`record_data` ADD `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `video_record`.`record_data` ADD `control_topic` varchar(32) DEFAULT '';
ALTER TABLE `video_record`.`record_data` ADD `room_id` int(4) DEFAULT 0 NOT NULL;
ALTER TABLE `video_record`.`record_data` ADD `encode_end_time` timestamp DEFAULT '1971-01-01 00:00:00';
ALTER TABLE `video_record`.`record_data` ADD `encode_end_realtime` timestamp DEFAULT '1971-01-01 00:00:00';
ALTER TABLE `video_record`.`record_data` ADD `encode_end_time_1st` timestamp DEFAULT '1971-01-01 00:00:00';
ALTER TABLE `video_record`.`mission_data` ADD `encode_end_time` timestamp DEFAULT '1971-01-01 00:00:00';
ALTER TABLE `video_record`.`mission_data` ADD `encode_evaluated_dura` int(4) DEFAULT 0;
ALTER TABLE `video_record`.`record_data` ADD `mission_start_id` int(4) DEFAULT 1 NOT NULL;
CREATE TABLE IF NOT EXISTS `video_record`.`mission_data`(
  `record_id` varchar(32) NOT NULL,
  `mission_id` int(8) NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8 NULL,
  `path` varchar(255) CHARACTER SET utf8 NULL,
  `status` int(2) NULL,
  PRIMARY KEY (`record_id`,`mission_id`)
);
ALTER TABLE `video_record`.`mission_data` DEFAULT  CHARSET=utf8mb4;
ALTER TABLE `video_record`.`mission_data` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

ALTER TABLE `video_record`.`mission_data` ADD `temp_files` varchar(3200) NULL;
ALTER TABLE `video_record`.`mission_data` ADD `del_temp_file` int(2) DEFAULT 0 NULL;
ALTER TABLE `video_record`.`mission_data` ADD `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `video_record`.`mission_data` ADD `file_addr` varchar(255) NULL;
ALTER TABLE `video_record`.`mission_data` ADD `mix_topic` varchar(255) NULL;
ALTER TABLE `video_record`.`mission_data` ADD `file_id` varchar(128) NULL;
ALTER TABLE `video_record`.`mission_data` ADD `duration`  bigint DEFAULT 0;
ALTER TABLE `video_record`.`mission_data` ADD `file_size`  bigint DEFAULT 0;
ALTER TABLE `video_record`.`mission_data` ADD `thumbnail_id` varchar(128) NULL;
CREATE TABLE IF NOT EXISTS `video_record`.`record_volume` (
  `app_id` varchar(64) NOT NULL,
  `use_volume` bigint(20) DEFAULT 0,
  `total_volume` bigint(20) DEFAULT 0,
  PRIMARY KEY (`app_id`)
);

CREATE TABLE IF NOT EXISTS `video_record`.`media_data`(
  `record_id` varchar(32) NOT NULL,
  `mission_id` int(8) NOT NULL,
  `media_index` varchar(64) NOT NULL,
  `media_info` varchar(1024) NOT NULL,
  PRIMARY KEY(`record_id`,`media_index`)
);
