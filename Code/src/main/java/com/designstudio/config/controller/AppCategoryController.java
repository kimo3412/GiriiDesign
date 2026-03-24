package com.designstudio.config.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsCategory;
import com.designstudio.config.domain.DsCustomField;
import com.designstudio.config.mapper.DsCategoryMapper;
import com.designstudio.config.mapper.DsCustomFieldMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 小程序端 - 公共配置接口
 */
@RestController
@RequestMapping("/api/v1/app/public/config")
@RequiredArgsConstructor
@Tag(name = "C端-配置信息")
public class AppCategoryController {

    private final DsCategoryMapper categoryMapper;
    private final DsCustomFieldMapper customFieldMapper;

    @GetMapping("/categories")
    @Operation(summary = "获取所有启用的品类")
    public R<List<DsCategory>> getActiveCategories() {
        return R.ok(categoryMapper.selectList(
                new LambdaQueryWrapper<DsCategory>()
                        .eq(DsCategory::getIsActive, 1)
                        .orderByAsc(DsCategory::getSortOrder)
        ));
    }

    @GetMapping("/categories/{id}/fields")
    @Operation(summary = "获取指定品类的动态表单字段")
    public R<List<DsCustomField>> getFieldsByCategory(@PathVariable Long id) {
        return R.ok(customFieldMapper.selectList(
                new LambdaQueryWrapper<DsCustomField>()
                        .eq(DsCustomField::getCategoryId, id)
                        .orderByAsc(DsCustomField::getSortOrder)
        ));
    }
}
