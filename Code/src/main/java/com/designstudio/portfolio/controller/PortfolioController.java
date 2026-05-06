package com.designstudio.portfolio.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.ListWithStats;
import com.designstudio.common.result.PageResult;
import com.designstudio.common.result.R;
import com.designstudio.portfolio.domain.DsPortfolio;
import com.designstudio.portfolio.mapper.DsPortfolioMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
    @Operation(summary = "作品集列表（支持分页）")
    public R<ListWithStats<DsPortfolio>> list(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") Long pageNum,
            @RequestParam(defaultValue = "10") Long pageSize) {
        LambdaQueryWrapper<DsPortfolio> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(DsPortfolio::getCategoryId, categoryId);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(DsPortfolio::getTitle, keyword);
        }
        wrapper.orderByDesc(DsPortfolio::getSortOrder, DsPortfolio::getCreateTime);
        Page<DsPortfolio> page = new Page<>(pageNum, pageSize);
        IPage<DsPortfolio> result = portfolioMapper.selectPage(page, wrapper);

        LambdaQueryWrapper<DsPortfolio> countWrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            countWrapper.like(DsPortfolio::getTitle, keyword);
        }
        List<DsPortfolio> all = portfolioMapper.selectList(countWrapper);
        Map<Long, Long> countMap = all.stream().collect(Collectors.groupingBy(
                p -> p.getCategoryId() == null ? 0L : p.getCategoryId(), Collectors.counting()));
        List<ListWithStats.CategoryStat> categoryStats = countMap.entrySet().stream()
                .map(e -> new ListWithStats.CategoryStat(null, e.getKey(), e.getValue()))
                .collect(Collectors.toList());

        return R.ok(ListWithStats.of(result.getRecords(), result.getTotal(), result.getCurrent(), result.getSize())
                .categoryStats(categoryStats));
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

    @DeleteMapping("/batch")
    @Operation(summary = "批量删除作品集")
    @OperLog("批量删除作品集")
    public R<Void> batchDelete(@RequestBody List<Long> ids) {
        for (Long id : ids) {
            portfolioMapper.deleteById(id);
        }
        return R.ok();
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "发布/下架作品集")
    @OperLog("发布/下架作品集")
    public R<Void> toggleStatus(@PathVariable Long id, @RequestBody DsPortfolio body) {
        DsPortfolio update = new DsPortfolio();
        update.setPortfolioId(id);
        update.setStatus(body.getStatus());
        portfolioMapper.updateById(update);
        return R.ok();
    }
}
