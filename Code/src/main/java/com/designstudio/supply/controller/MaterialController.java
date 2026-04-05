package com.designstudio.supply.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.supply.domain.DsMaterial;
import com.designstudio.supply.mapper.DsMaterialMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * 物料管理
 */
@RestController
@RequestMapping("/api/v1/admin/materials")
@RequiredArgsConstructor
@Tag(name = "物料管理")
public class MaterialController {

    private final DsMaterialMapper materialMapper;

    @GetMapping
    @Operation(summary = "物料列表")
    public R<List<DsMaterial>> list(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<DsMaterial> wrapper = new LambdaQueryWrapper<>();
        if (category != null && !category.isEmpty()) {
            wrapper.eq(DsMaterial::getCategory, category);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(DsMaterial::getName, keyword).or().like(DsMaterial::getSku, keyword));
        }
        wrapper.orderByDesc(DsMaterial::getCreateTime);
        return R.ok(materialMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "物料详情")
    public R<DsMaterial> get(@PathVariable Long id) {
        return R.ok(materialMapper.selectById(id));
    }

    @PostMapping
    @Operation(summary = "新增物料")
    @OperLog("新增物料")
    public R<Void> add(@RequestBody DsMaterial material) {
        materialMapper.insert(material);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改物料")
    @OperLog("修改物料")
    public R<Void> update(@PathVariable Long id, @RequestBody DsMaterial dto) {
        DsMaterial material = materialMapper.selectById(id);
        if (material == null) return R.fail("物料不存在");

        material.setName(dto.getName());
        material.setSku(dto.getSku());
        material.setCategory(dto.getCategory());
        material.setUnit(dto.getUnit());
        material.setUnitPrice(dto.getUnitPrice());
        material.setWarningStock(dto.getWarningStock());
        material.setImageUrl(dto.getImageUrl());
        material.setRemark(dto.getRemark());
        materialMapper.updateById(material);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除物料")
    @OperLog("删除物料")
    public R<Void> delete(@PathVariable Long id) {
        materialMapper.deleteById(id);
        return R.ok();
    }

    // ==================== 入库/出库 ====================

    @PostMapping("/{id}/stock-in")
    @Operation(summary = "入库")
    @OperLog("物料入库")
    public R<Void> stockIn(@PathVariable Long id, @RequestBody StockDTO dto) {
        DsMaterial material = materialMapper.selectById(id);
        if (material == null) return R.fail("物料不存在");

        material.setStock(material.getStock().add(dto.getQuantity()));
        materialMapper.updateById(material);
        return R.ok();
    }

    @PostMapping("/{id}/stock-out")
    @Operation(summary = "出库")
    @OperLog("物料出库")
    public R<Void> stockOut(@PathVariable Long id, @RequestBody StockDTO dto) {
        DsMaterial material = materialMapper.selectById(id);
        if (material == null) return R.fail("物料不存在");

        if (material.getStock().compareTo(dto.getQuantity()) < 0) {
            return R.fail("库存不足，当前库存：" + material.getStock());
        }

        material.setStock(material.getStock().subtract(dto.getQuantity()));
        materialMapper.updateById(material);
        return R.ok();
    }

    @GetMapping("/low-stock")
    @Operation(summary = "库存预警列表")
    public R<List<DsMaterial>> lowStock() {
        List<DsMaterial> all = materialMapper.selectList(null);
        List<DsMaterial> lowList = all.stream()
                .filter(m -> m.getWarningStock() != null && m.getStock().compareTo(m.getWarningStock()) <= 0)
                .toList();
        return R.ok(lowList);
    }

    @Data
    public static class StockDTO {
        private BigDecimal quantity;
        private String remark;
    }
}
