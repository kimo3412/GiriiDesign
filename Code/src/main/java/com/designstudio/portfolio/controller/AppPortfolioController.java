package com.designstudio.portfolio.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.portfolio.domain.DsPortfolio;
import com.designstudio.portfolio.mapper.DsPortfolioMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 小程序端 - 作品集公共接口
 */
@RestController
@RequestMapping("/api/v1/app/public/portfolios")
@RequiredArgsConstructor
@Tag(name = "C端-作品集")
public class AppPortfolioController {

    private final DsPortfolioMapper portfolioMapper;

    @GetMapping
    @Operation(summary = "作品集列表（瀑布流）")
    public R<List<DsPortfolio>> list(@RequestParam(required = false) Long categoryId) {
        LambdaQueryWrapper<DsPortfolio> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DsPortfolio::getStatus, 1); // 仅查询已发布
        if (categoryId != null) {
            wrapper.eq(DsPortfolio::getCategoryId, categoryId);
        }
        wrapper.orderByDesc(DsPortfolio::getSortOrder, DsPortfolio::getCreateTime);
        return R.ok(portfolioMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取作品详情并增加浏览量")
    public R<DsPortfolio> detail(@PathVariable Long id) {
        DsPortfolio portfolio = portfolioMapper.selectById(id);
        if (portfolio != null) {
            // 增加浏览量
            portfolio.setViewCount(portfolio.getViewCount() + 1);
            portfolioMapper.updateById(portfolio);
        }
        return R.ok(portfolio);
    }
}
