package com.designstudio.config.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.config.domain.DsBanner;
import com.designstudio.config.mapper.DsBannerMapper;
import com.designstudio.config.service.BannerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 轮播图 Service 实现
 */
@Service
@RequiredArgsConstructor
public class BannerServiceImpl implements BannerService {

    private final DsBannerMapper bannerMapper;

    @Override
    public List<DsBanner> listEnabled() {
        return bannerMapper.selectList(
                new LambdaQueryWrapper<DsBanner>()
                        .eq(DsBanner::getStatus, 1)
                        .orderByDesc(DsBanner::getSortOrder)
                        .orderByDesc(DsBanner::getCreateTime)
        );
    }

    @Override
    public IPage<DsBanner> listBanners(Long pageNum, Long pageSize) {
        LambdaQueryWrapper<DsBanner> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(DsBanner::getSortOrder).orderByDesc(DsBanner::getCreateTime);
        Page<DsBanner> page = new Page<>(pageNum, pageSize);
        return bannerMapper.selectPage(page, wrapper);
    }

    @Override
    public DsBanner getBanner(Long id) {
        return bannerMapper.selectById(id);
    }

    @Override
    public void addBanner(DsBanner banner) {
        bannerMapper.insert(banner);
    }

    @Override
    public void updateBanner(Long id, DsBanner banner) {
        banner.setBannerId(id);
        bannerMapper.updateById(banner);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteBanner(Long id) {
        bannerMapper.deleteById(id);
    }
}
