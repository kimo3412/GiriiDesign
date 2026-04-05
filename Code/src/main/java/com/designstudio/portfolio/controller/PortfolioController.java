package com.designstudio.portfolio.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.portfolio.domain.DsPortfolio;
import com.designstudio.portfolio.mapper.DsPortfolioMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * B端 - 作品集管理
 */
@RestController
@RequestMapping("/api/v1/admin/portfolios")
@RequiredArgsConstructor
@Tag(name = "B端-作品集管理")
public class PortfolioController {

    private final DsPortfolioMapper portfolioMapper;

    @GetMapping
    @Operation(summary = "作品集列表")
    public R<List<DsPortfolio>> list(@RequestParam(required = false) Long categoryId,
                                     @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<DsPortfolio> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(DsPortfolio::getCategoryId, categoryId);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(DsPortfolio::getTitle, keyword);
        }
        wrapper.orderByDesc(DsPortfolio::getSortOrder, DsPortfolio::getCreateTime);
        return R.ok(portfolioMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "详情")
    public R<DsPortfolio> get(@PathVariable Long id) {
        return R.ok(portfolioMapper.selectById(id));
    }

    @PostMapping
    @Operation(summary = "新增作品集")
    @OperLog("新增作品集")
    public R<Void> add(@RequestBody DsPortfolio portfolio) {
        portfolio.setViewCount(0);
        portfolioMapper.insert(portfolio);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改作品集")
    @OperLog("修改作品集")
    public R<Void> update(@PathVariable Long id, @RequestBody DsPortfolio portfolio) {
        portfolio.setPortfolioId(id);
        portfolioMapper.updateById(portfolio);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除作品集")
    @OperLog("删除作品集")
    public R<Void> delete(@PathVariable Long id) {
        portfolioMapper.deleteById(id);
        return R.ok();
    }
}
