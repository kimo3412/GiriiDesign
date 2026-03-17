package com.designstudio.supply.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.supply.domain.DsBomTemplate;
import com.designstudio.supply.domain.DsBomTemplateItem;
import com.designstudio.supply.mapper.DsBomTemplateItemMapper;
import com.designstudio.supply.mapper.DsBomTemplateMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
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

    private final DsBomTemplateMapper templateMapper;
    private final DsBomTemplateItemMapper itemMapper;

    @GetMapping
    @Operation(summary = "BOM模板列表")
    public R<List<DsBomTemplate>> list(@RequestParam(required = false) Long categoryId) {
        LambdaQueryWrapper<DsBomTemplate> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(DsBomTemplate::getCategoryId, categoryId);
        }
        wrapper.orderByDesc(DsBomTemplate::getCreateTime);
        return R.ok(templateMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取模板详情（含物料明细）")
    public R<BomDetailVO> get(@PathVariable Long id) {
        DsBomTemplate template = templateMapper.selectById(id);
        if (template == null) return R.fail("模板不存在");

        List<DsBomTemplateItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<DsBomTemplateItem>().eq(DsBomTemplateItem::getTemplateId, id));

        BomDetailVO vo = new BomDetailVO();
        vo.setTemplate(template);
        vo.setItems(items);
        return R.ok(vo);
    }

    @PostMapping
    @Operation(summary = "新增BOM模板")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> add(@RequestBody BomSaveDTO dto) {
        DsBomTemplate template = new DsBomTemplate();
        template.setName(dto.getName());
        template.setCategoryId(dto.getCategoryId());
        template.setRemark(dto.getRemark());
        templateMapper.insert(template);

        if (dto.getItems() != null) {
            for (BomItemDTO item : dto.getItems()) {
                DsBomTemplateItem entity = new DsBomTemplateItem();
                entity.setTemplateId(template.getTemplateId());
                entity.setMaterialId(item.getMaterialId());
                entity.setQuantity(item.getQuantity());
                entity.setDelFlag(0);
                itemMapper.insert(entity);
            }
        }
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改BOM模板（全量覆盖明细）")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> update(@PathVariable Long id, @RequestBody BomSaveDTO dto) {
        DsBomTemplate template = templateMapper.selectById(id);
        if (template == null) return R.fail("模板不存在");

        template.setName(dto.getName());
        template.setCategoryId(dto.getCategoryId());
        template.setRemark(dto.getRemark());
        templateMapper.updateById(template);

        // 清除旧明细，插入新的
        itemMapper.delete(new LambdaQueryWrapper<DsBomTemplateItem>()
                .eq(DsBomTemplateItem::getTemplateId, id));
        if (dto.getItems() != null) {
            for (BomItemDTO item : dto.getItems()) {
                DsBomTemplateItem entity = new DsBomTemplateItem();
                entity.setTemplateId(id);
                entity.setMaterialId(item.getMaterialId());
                entity.setQuantity(item.getQuantity());
                entity.setDelFlag(0);
                itemMapper.insert(entity);
            }
        }
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除BOM模板")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> delete(@PathVariable Long id) {
        templateMapper.deleteById(id);
        itemMapper.delete(new LambdaQueryWrapper<DsBomTemplateItem>()
                .eq(DsBomTemplateItem::getTemplateId, id));
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
