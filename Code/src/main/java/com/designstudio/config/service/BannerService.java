package com.designstudio.config.service;

import com.designstudio.config.domain.DsBanner;
import com.baomidou.mybatisplus.core.metadata.IPage;
import java.util.List;

/**
 * 轮播图 Service
 */
public interface BannerService {

    /** C端 - 获取启用的轮播图列表 */
    List<DsBanner> listEnabled();

    /** 后台 - 分页获取轮播图列表 */
    IPage<DsBanner> listBanners(Long pageNum, Long pageSize);

    /** 后台 - 获取详情 */
    DsBanner getBanner(Long id);

    /** 后台 - 新增 */
    void addBanner(DsBanner banner);

    /** 后台 - 修改 */
    void updateBanner(Long id, DsBanner banner);

    /** 后台 - 删除 */
    void deleteBanner(Long id);
}
