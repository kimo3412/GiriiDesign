-- =====================================================
-- V7: create ai config table
-- Date: 2026-04-20
-- =====================================================

CREATE TABLE IF NOT EXISTS `ds_ai_config` (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `provider_name` varchar(100) DEFAULT NULL COMMENT 'Provider name',
  `enabled` tinyint(1) DEFAULT 0 COMMENT 'Enabled flag',
  `api_url` varchar(500) DEFAULT NULL COMMENT 'OpenAI compatible endpoint',
  `api_key` varchar(500) DEFAULT NULL COMMENT 'API key',
  `model` varchar(100) DEFAULT NULL COMMENT 'Model name',
  `system_prompt` text COMMENT 'System prompt',
  `create_by` bigint DEFAULT NULL COMMENT 'Created by',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Created time',
  `update_by` bigint DEFAULT NULL COMMENT 'Updated by',
  `update_time` datetime DEFAULT NULL COMMENT 'Updated time',
  `del_flag` tinyint(1) DEFAULT 0 COMMENT 'Logical delete flag',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI customer service config';
