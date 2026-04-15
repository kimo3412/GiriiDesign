package com.designstudio.supply.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.supply.controller.BomTemplateController;
import com.designstudio.supply.domain.DsBomTemplate;
import com.designstudio.supply.domain.DsBomTemplateItem;
import com.designstudio.supply.domain.DsMaterial;
import com.designstudio.supply.mapper.DsBomTemplateItemMapper;
import com.designstudio.supply.mapper.DsBomTemplateMapper;
import com.designstudio.supply.mapper.DsMaterialMapper;
import com.designstudio.supply.service.BomTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * BOM模板业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class BomTemplateServiceImpl implements BomTemplateService {

    private final DsBomTemplateMapper templateMapper;
    private final DsBomTemplateItemMapper itemMapper;
    private final DsMaterialMapper materialMapper;

    @Override
    public IPage<DsBomTemplate> listTemplates(Long categoryId, Long pageNum, Long pageSize) {
        LambdaQueryWrapper<DsBomTemplate> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(DsBomTemplate::getCategoryId, categoryId);
        }
        wrapper.orderByDesc(DsBomTemplate::getCreateTime);
        Page<DsBomTemplate> page = new Page<>(pageNum, pageSize);
        return templateMapper.selectPage(page, wrapper);
    }

    @Override
    public BomTemplateController.BomDetailVO getTemplateDetail(Long id) {
        DsBomTemplate template = templateMapper.selectById(id);
        if (template == null) return null;

        List<DsBomTemplateItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<DsBomTemplateItem>().eq(DsBomTemplateItem::getTemplateId, id));

        // 填充物料名称、SKU、单价
        Set<Long> materialIds = items.stream()
                .map(DsBomTemplateItem::getMaterialId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (!materialIds.isEmpty()) {
            Map<Long, DsMaterial> materialMap = materialMapper.selectBatchIds(materialIds).stream()
                    .collect(Collectors.toMap(DsMaterial::getMaterialId, m -> m, (a, b) -> a));
            for (DsBomTemplateItem item : items) {
                DsMaterial material = materialMap.get(item.getMaterialId());
                if (material != null) {
                    item.setMaterialName(material.getName());
                    item.setMaterialSku(material.getSku());
                    item.setUnitPrice(material.getUnitPrice());
                }
            }
        }

        BomTemplateController.BomDetailVO vo = new BomTemplateController.BomDetailVO();
        vo.setTemplate(template);
        vo.setItems(items);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addTemplate(BomTemplateController.BomSaveDTO dto) {
        DsBomTemplate template = new DsBomTemplate();
        template.setName(dto.getName());
        template.setCategoryId(dto.getCategoryId());
        template.setRemark(dto.getRemark());
        templateMapper.insert(template);

        insertItems(template.getTemplateId(), dto.getItems());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTemplate(Long id, BomTemplateController.BomSaveDTO dto) {
        DsBomTemplate template = templateMapper.selectById(id);
        if (template == null) throw new RuntimeException("模板不存在");

        template.setName(dto.getName());
        template.setCategoryId(dto.getCategoryId());
        template.setRemark(dto.getRemark());
        templateMapper.updateById(template);

        // 清除旧明细，插入新的
        itemMapper.delete(new LambdaQueryWrapper<DsBomTemplateItem>()
                .eq(DsBomTemplateItem::getTemplateId, id));
        insertItems(id, dto.getItems());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTemplate(Long id) {
        templateMapper.deleteById(id);
        itemMapper.delete(new LambdaQueryWrapper<DsBomTemplateItem>()
                .eq(DsBomTemplateItem::getTemplateId, id));
    }

    private void insertItems(Long templateId, List<BomTemplateController.BomItemDTO> items) {
        if (items == null) return;
        for (BomTemplateController.BomItemDTO item : items) {
            DsBomTemplateItem entity = new DsBomTemplateItem();
            entity.setTemplateId(templateId);
            entity.setMaterialId(item.getMaterialId());
            entity.setQuantity(item.getQuantity());
            entity.setDelFlag(0);
            itemMapper.insert(entity);
        }
    }
}
