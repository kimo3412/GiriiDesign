package com.designstudio.config.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.ListWithStats;
import com.designstudio.common.result.PageResult;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsBanner;
import com.designstudio.config.service.BannerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 后台 - 轮播图管理
 */
@RestController
@RequestMapping("/api/v1/admin/banners")
@RequiredArgsConstructor
@Tag(name = "轮播图管理")
public class BannerController {

    private final BannerService bannerService;

    @GetMapping
    @Operation(summary = "轮播图列表（分页）")
    public R<ListWithStats<DsBanner>> list(
            @RequestParam(defaultValue = "1") Long pageNum,
            @RequestParam(defaultValue = "10") Long pageSize) {
        IPage<DsBanner> page = bannerService.listBanners(pageNum, pageSize);
        long totalActive = page.getRecords().stream().filter(r -> r.getStatus() == 1).count();
        long totalInactive = page.getRecords().stream().filter(r -> r.getStatus() == 0).count();
        Map<String, Long> stats = new HashMap<>();
        stats.put("active", totalActive);
        stats.put("inactive", totalInactive);
        return R.ok(ListWithStats.of(page.getRecords(), page.getTotal(), page.getCurrent(), page.getSize()).stats(stats));
    }

    @GetMapping("/{id}")
    @Operation(summary = "轮播图详情")
    public R<DsBanner> get(@PathVariable Long id) {
        return R.ok(bannerService.getBanner(id));
    }

    @PostMapping
    @Operation(summary = "新增轮播图")
    @OperLog("新增轮播图")
    public R<Void> add(@RequestBody BannerSaveDTO dto) {
        DsBanner banner = new DsBanner();
        banner.setTitle(dto.getTitle());
        banner.setImageUrl(dto.getImageUrl());
        banner.setLinkUrl(dto.getLinkUrl());
        banner.setLinkType(dto.getLinkType());
        banner.setSortOrder(dto.getSortOrder());
        banner.setStatus(dto.getStatus());
        bannerService.addBanner(banner);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改轮播图")
    @OperLog("修改轮播图")
    public R<Void> update(@PathVariable Long id, @RequestBody BannerSaveDTO dto) {
        DsBanner banner = new DsBanner();
        banner.setTitle(dto.getTitle());
        banner.setImageUrl(dto.getImageUrl());
        banner.setLinkUrl(dto.getLinkUrl());
        banner.setLinkType(dto.getLinkType());
        banner.setSortOrder(dto.getSortOrder());
        banner.setStatus(dto.getStatus());
        bannerService.updateBanner(id, banner);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除轮播图")
    @OperLog("删除轮播图")
    public R<Void> delete(@PathVariable Long id) {
        bannerService.deleteBanner(id);
        return R.ok();
    }

    @Data
    public static class BannerSaveDTO {
        private String title;
        private String imageUrl;
        private String linkUrl;
        private String linkType;
        private Integer sortOrder;
        private Integer status;
    }
}
