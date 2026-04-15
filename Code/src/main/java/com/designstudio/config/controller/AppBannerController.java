package com.designstudio.config.controller;

import com.designstudio.config.domain.DsBanner;
import com.designstudio.config.service.BannerService;
import com.designstudio.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * C端 - 轮播图接口
 */
@RestController
@RequestMapping("/api/v1/app/public/banners")
@RequiredArgsConstructor
@Tag(name = "C端-轮播图")
public class AppBannerController {

    private final BannerService bannerService;

    @GetMapping
    @Operation(summary = "获取轮播图列表（小程序首页用）")
    public R<List<DsBanner>> list() {
        return R.ok(bannerService.listEnabled());
    }
}
