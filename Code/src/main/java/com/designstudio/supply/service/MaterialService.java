package com.designstudio.supply.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.designstudio.common.result.ListWithStats;
import com.designstudio.supply.domain.DsMaterial;

import java.math.BigDecimal;
import java.util.List;

/**
 * 物料业务 Service
 */
public interface MaterialService {

    IPage<DsMaterial> listMaterials(String category, String keyword, Long pageNum, Long pageSize);

    List<ListWithStats.CategoryStat> listCategoryStats(String category, String keyword);

    DsMaterial getMaterial(Long id);

    void addMaterial(DsMaterial material);

    void updateMaterial(Long id, DsMaterial dto);

    void deleteMaterial(Long id);

    void stockIn(Long id, BigDecimal quantity);

    void stockOut(Long id, BigDecimal quantity);

    List<DsMaterial> getLowStockMaterials();
}
