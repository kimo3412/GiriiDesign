package com.designstudio.supply.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.designstudio.supply.controller.BomTemplateController;
import com.designstudio.supply.domain.DsBomTemplate;
import com.designstudio.supply.domain.DsBomTemplateItem;

import java.util.List;

/**
 * BOM模板业务 Service
 */
public interface BomTemplateService {

    IPage<DsBomTemplate> listTemplates(Long categoryId, Long pageNum, Long pageSize);

    BomTemplateController.BomDetailVO getTemplateDetail(Long id);

    void addTemplate(BomTemplateController.BomSaveDTO dto);

    void updateTemplate(Long id, BomTemplateController.BomSaveDTO dto);

    void deleteTemplate(Long id);
}
