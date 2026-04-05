package com.designstudio.config.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsCustomField;
import com.designstudio.config.mapper.DsCustomFieldMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 动态字段配置
 */
@RestController
@RequestMapping("/api/v1/admin/categories/{categoryId}/fields")
@RequiredArgsConstructor
@Tag(name = "动态字段配置")
public class CustomFieldController {

    private final DsCustomFieldMapper fieldMapper;

    @GetMapping
    @Operation(summary = "获取品类下的字段列表")
    public R<List<DsCustomField>> list(@PathVariable Long categoryId) {
        List<DsCustomField> list = fieldMapper.selectList(
                new LambdaQueryWrapper<DsCustomField>()
                        .eq(DsCustomField::getCategoryId, categoryId)
                        .orderByAsc(DsCustomField::getSortOrder));
        return R.ok(list);
    }

    @PostMapping
    @Operation(summary = "保存字段列表（全量覆盖）")
    @OperLog("保存动态字段")
    public R<Void> save(@PathVariable Long categoryId, @RequestBody List<DsCustomField> fields) {
        // 先删除该品类下的所有字段
        fieldMapper.delete(
                new LambdaQueryWrapper<DsCustomField>()
                        .eq(DsCustomField::getCategoryId, categoryId));
        // 再批量插入
        for (int i = 0; i < fields.size(); i++) {
            DsCustomField field = fields.get(i);
            field.setFieldId(null); // 清除ID，重新生成
            field.setCategoryId(categoryId);
            field.setSortOrder(i + 1);
            fieldMapper.insert(field);
        }
        return R.ok();
    }

    @DeleteMapping("/{fieldId}")
    @Operation(summary = "删除单个字段")
    @OperLog("删除动态字段")
    public R<Void> delete(@PathVariable Long categoryId, @PathVariable Long fieldId) {
        fieldMapper.deleteById(fieldId);
        return R.ok();
    }
}
