package com.designstudio.config.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsCategory;
import com.designstudio.config.mapper.DsCategoryMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 品类管理
 */
@RestController
@RequestMapping("/api/v1/admin/categories")
@RequiredArgsConstructor
@Tag(name = "品类管理")
public class CategoryController {

    private final DsCategoryMapper categoryMapper;

    @GetMapping
    @Operation(summary = "品类列表")
    public R<List<DsCategory>> list() {
        List<DsCategory> list = categoryMapper.selectList(
                new LambdaQueryWrapper<DsCategory>().orderByAsc(DsCategory::getSortOrder));
        return R.ok(list);
    }

    @GetMapping("/{id}")
    @Operation(summary = "品类详情")
    public R<DsCategory> detail(@PathVariable Long id) {
        return R.ok(categoryMapper.selectById(id));
    }

    @PostMapping
    @Operation(summary = "新增品类")
    @OperLog("新增品类")
    public R<Void> add(@RequestBody DsCategory category) {
        categoryMapper.insert(category);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改品类")
    @OperLog("修改品类")
    public R<Void> update(@PathVariable Long id, @RequestBody DsCategory category) {
        category.setCategoryId(id);
        categoryMapper.updateById(category);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除品类")
    @OperLog("删除品类")
    public R<Void> delete(@PathVariable Long id) {
        categoryMapper.deleteById(id);
        return R.ok();
    }
}
