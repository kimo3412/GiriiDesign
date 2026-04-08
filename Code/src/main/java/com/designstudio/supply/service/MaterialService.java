package com.designstudio.supply.service;

import com.designstudio.supply.controller.MaterialController;
import com.designstudio.supply.domain.DsMaterial;

import java.math.BigDecimal;
import java.util.List;

/**
 * 物料业务 Service
 */
public interface MaterialService {

    List<DsMaterial> listMaterials(String category, String keyword);

    DsMaterial getMaterial(Long id);

    void addMaterial(DsMaterial material);

    void updateMaterial(Long id, DsMaterial dto);

    void deleteMaterial(Long id);

    void stockIn(Long id, BigDecimal quantity);

    void stockOut(Long id, BigDecimal quantity);

    List<DsMaterial> getLowStockMaterials();
}
