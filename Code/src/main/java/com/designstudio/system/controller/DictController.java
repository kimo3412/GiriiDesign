package com.designstudio.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysDictData;
import com.designstudio.system.domain.SysDictType;
import com.designstudio.system.mapper.SysDictDataMapper;
import com.designstudio.system.mapper.SysDictTypeMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 数据字典管理
 */
@RestController
@RequestMapping("/api/v1/admin/dict")
@RequiredArgsConstructor
@Tag(name = "数据字典")
public class DictController {

    private final SysDictTypeMapper dictTypeMapper;
    private final SysDictDataMapper dictDataMapper;

    // ============= 字典类型 =============

    @GetMapping("/types")
    @Operation(summary = "字典类型列表")
    public R<List<SysDictType>> typeList() {
        return R.ok(dictTypeMapper.selectList(null));
    }

    @PostMapping("/types")
    @Operation(summary = "新增字典类型")
    public R<Void> addType(@RequestBody SysDictType dictType) {
        dictTypeMapper.insert(dictType);
        return R.ok();
    }

    @PutMapping("/types/{id}")
    @Operation(summary = "修改字典类型")
    public R<Void> updateType(@PathVariable Long id, @RequestBody SysDictType dictType) {
        dictType.setDictId(id);
        dictTypeMapper.updateById(dictType);
        return R.ok();
    }

    @DeleteMapping("/types/{id}")
    @Operation(summary = "删除字典类型")
    public R<Void> deleteType(@PathVariable Long id) {
        dictTypeMapper.deleteById(id);
        return R.ok();
    }

    // ============= 字典数据 =============

    @GetMapping("/data/{dictType}")
    @Operation(summary = "根据字典类型查询数据列表")
    public R<List<SysDictData>> dataList(@PathVariable String dictType) {
        List<SysDictData> list = dictDataMapper.selectList(
                new LambdaQueryWrapper<SysDictData>()
                        .eq(SysDictData::getDictType, dictType)
                        .orderByAsc(SysDictData::getSortOrder));
        return R.ok(list);
    }

    @PostMapping("/data")
    @Operation(summary = "新增字典数据")
    public R<Void> addData(@RequestBody SysDictData dictData) {
        dictDataMapper.insert(dictData);
        return R.ok();
    }

    @PutMapping("/data/{id}")
    @Operation(summary = "修改字典数据")
    public R<Void> updateData(@PathVariable Long id, @RequestBody SysDictData dictData) {
        dictData.setDictCode(id);
        dictDataMapper.updateById(dictData);
        return R.ok();
    }

    @DeleteMapping("/data/{id}")
    @Operation(summary = "删除字典数据")
    public R<Void> deleteData(@PathVariable Long id) {
        dictDataMapper.deleteById(id);
        return R.ok();
    }
}
