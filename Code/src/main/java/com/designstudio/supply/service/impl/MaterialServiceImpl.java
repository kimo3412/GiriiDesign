package com.designstudio.supply.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.common.result.ListWithStats;
import com.designstudio.supply.domain.DsMaterial;
import com.designstudio.supply.mapper.DsMaterialMapper;
import com.designstudio.supply.service.MaterialService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 物料业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class MaterialServiceImpl implements MaterialService {

    private final DsMaterialMapper materialMapper;

    @Override
    public IPage<DsMaterial> listMaterials(String category, String keyword, Long pageNum, Long pageSize) {
        LambdaQueryWrapper<DsMaterial> wrapper = new LambdaQueryWrapper<>();
        if (category != null && !category.isEmpty()) {
            wrapper.eq(DsMaterial::getCategory, category);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(DsMaterial::getName, keyword).or().like(DsMaterial::getSku, keyword));
        }
        wrapper.orderByDesc(DsMaterial::getCreateTime);
        Page<DsMaterial> page = new Page<>(pageNum, pageSize);
        return materialMapper.selectPage(page, wrapper);
    }

    @Override
    public List<ListWithStats.CategoryStat> listCategoryStats(String category, String keyword) {
        LambdaQueryWrapper<DsMaterial> wrapper = new LambdaQueryWrapper<>();
        if (category != null && !category.isEmpty()) {
            wrapper.eq(DsMaterial::getCategory, category);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(DsMaterial::getName, keyword).or().like(DsMaterial::getSku, keyword));
        }
        List<DsMaterial> all = materialMapper.selectList(wrapper);
        Map<String, Long> countMap = new HashMap<>();
        for (DsMaterial m : all) {
            String cat = m.getCategory() == null ? "未分类" : m.getCategory();
            countMap.merge(cat, 1L, Long::sum);
        }
        return countMap.entrySet().stream()
                .map(e -> new ListWithStats.CategoryStat(e.getKey(), null, e.getValue()))
                .collect(Collectors.toList());
    }

    @Override
    public DsMaterial getMaterial(Long id) {
        return materialMapper.selectById(id);
    }

    @Override
    public void addMaterial(DsMaterial material) {
        materialMapper.insert(material);
    }

    @Override
    public void updateMaterial(Long id, DsMaterial dto) {
        DsMaterial material = materialMapper.selectById(id);
        if (material == null) throw new RuntimeException("物料不存在");

        material.setName(dto.getName());
        material.setSku(dto.getSku());
        material.setCategory(dto.getCategory());
        material.setUnit(dto.getUnit());
        material.setUnitPrice(dto.getUnitPrice());
        material.setWarningStock(dto.getWarningStock());
        material.setImageUrl(dto.getImageUrl());
        material.setRemark(dto.getRemark());
        materialMapper.updateById(material);
    }

    @Override
    public void deleteMaterial(Long id) {
        materialMapper.deleteById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void stockIn(Long id, BigDecimal quantity) {
        DsMaterial material = materialMapper.selectById(id);
        if (material == null) throw new RuntimeException("物料不存在");

        material.setStock(material.getStock().add(quantity));
        materialMapper.updateById(material);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void stockOut(Long id, BigDecimal quantity) {
        DsMaterial material = materialMapper.selectById(id);
        if (material == null) throw new RuntimeException("物料不存在");

        if (material.getStock().compareTo(quantity) < 0) {
            throw new RuntimeException("库存不足，当前库存：" + material.getStock());
        }

        material.setStock(material.getStock().subtract(quantity));
        materialMapper.updateById(material);
    }

    @Override
    public List<DsMaterial> getLowStockMaterials() {
        return materialMapper.selectList(
                new LambdaQueryWrapper<DsMaterial>()
                        .isNotNull(DsMaterial::getWarningStock)
                        .apply("stock <= warning_stock"));
    }
}
