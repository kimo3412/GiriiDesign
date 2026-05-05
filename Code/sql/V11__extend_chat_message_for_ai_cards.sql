-- Support AI/system messages and structured chat cards.
ALTER TABLE ds_chat_message
    MODIFY COLUMN sender_id bigint NULL COMMENT 'sender id, nullable for AI/system messages';

ALTER TABLE ds_chat_message
    MODIFY COLUMN content_type tinyint(1) NULL DEFAULT 0 COMMENT '0=text,1=image,2=file,3=order progress card,4=action card';

ALTER TABLE ds_chat_message
    ADD COLUMN extra_json json NULL COMMENT 'structured message payload' AFTER content;
