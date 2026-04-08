package com.designstudio.supply.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.supply.domain.DsMaterial;
import com.designstudio.supply.service.MaterialService;
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

    private final MaterialService materialService;

    @GetMapping
    @Operation(summary = "物料列表")
    public R<List<DsMaterial>> list(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        return R.ok(materialService.listMaterials(category, keyword));
    }

    @GetMapping("/{id}")
    @Operation(summary = "物料详情")
    public R<DsMaterial> get(@PathVariable Long id) {
        return R.ok(materialService.getMaterial(id));
    }

    @PostMapping
    @Operation(summary = "新增物料")
    @OperLog("新增物料")
    public R<Void> add(@RequestBody DsMaterial material) {
        materialService.addMaterial(material);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改物料")
    @OperLog("修改物料")
    public R<Void> update(@PathVariable Long id, @RequestBody DsMaterial dto) {
        try {
            materialService.updateMaterial(id, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除物料")
    @OperLog("删除物料")
    public R<Void> delete(@PathVariable Long id) {
        materialService.deleteMaterial(id);
        return R.ok();
    }

    @PostMapping("/{id}/stock-in")
    @Operation(summary = "入库")
    @OperLog("物料入库")
    public R<Void> stockIn(@PathVariable Long id, @RequestBody StockDTO dto) {
        try {
            materialService.stockIn(id, dto.getQuantity());
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{id}/stock-out")
    @Operation(summary = "出库")
    @OperLog("物料出库")
    public R<Void> stockOut(@PathVariable Long id, @RequestBody StockDTO dto) {
        try {
            materialService.stockOut(id, dto.getQuantity());
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @GetMapping("/low-stock")
    @Operation(summary = "库存预警列表")
    public R<List<DsMaterial>> lowStock() {
        return R.ok(materialService.getLowStockMaterials());
    }

    @Data
    public static class StockDTO {
        private BigDecimal quantity;
        private String remark;
    }
}
