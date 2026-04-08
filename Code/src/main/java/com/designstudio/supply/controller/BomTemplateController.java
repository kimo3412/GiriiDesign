package com.designstudio.supply.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.supply.domain.DsBomTemplate;
import com.designstudio.supply.domain.DsBomTemplateItem;
import com.designstudio.supply.service.BomTemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * BOM模板管理
 */
@RestController
@RequestMapping("/api/v1/admin/bom-templates")
@RequiredArgsConstructor
@Tag(name = "BOM模板管理")
public class BomTemplateController {

    private final BomTemplateService bomTemplateService;

    @GetMapping
    @Operation(summary = "BOM模板列表")
    public R<List<DsBomTemplate>> list(@RequestParam(required = false) Long categoryId) {
        return R.ok(bomTemplateService.listTemplates(categoryId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取模板详情（含物料明细）")
    public R<BomDetailVO> get(@PathVariable Long id) {
        BomDetailVO vo = bomTemplateService.getTemplateDetail(id);
        if (vo == null) return R.fail("模板不存在");
        return R.ok(vo);
    }

    @PostMapping
    @Operation(summary = "新增BOM模板")
    @OperLog("新增BOM模板")
    public R<Void> add(@RequestBody BomSaveDTO dto) {
        bomTemplateService.addTemplate(dto);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改BOM模板（全量覆盖明细）")
    @OperLog("修改BOM模板")
    public R<Void> update(@PathVariable Long id, @RequestBody BomSaveDTO dto) {
        try {
            bomTemplateService.updateTemplate(id, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除BOM模板")
    @OperLog("删除BOM模板")
    public R<Void> delete(@PathVariable Long id) {
        bomTemplateService.deleteTemplate(id);
        return R.ok();
    }

    // ========== VO / DTO ==========

    @Data
    public static class BomDetailVO {
        private DsBomTemplate template;
        private List<DsBomTemplateItem> items;
    }

    @Data
    public static class BomSaveDTO {
        private String name;
        private Long categoryId;
        private String remark;
        private List<BomItemDTO> items;
    }

    @Data
    public static class BomItemDTO {
        private Long materialId;
        private BigDecimal quantity;
    }
}
