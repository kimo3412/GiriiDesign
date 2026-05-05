-- Support AI/system messages and structured chat cards.
ALTER TABLE ds_chat_message
    MODIFY COLUMN sender_id bigint NULL COMMENT '发送方ID，AI/系统消息可为空或为0';

ALTER TABLE ds_chat_message
    MODIFY COLUMN content_type tinyint(1) NULL DEFAULT 0 COMMENT '0=文本,1=图片,3=订单进度卡片,4=动作帮助卡片';

ALTER TABLE ds_chat_message
    ADD COLUMN extra_json json NULL COMMENT '结构化消息扩展数据' AFTER content;
