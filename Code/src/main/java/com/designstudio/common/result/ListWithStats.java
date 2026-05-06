package com.designstudio.common.result;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * 带聚合统计的分页列表返回
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListWithStats<T> implements Serializable {

    private List<T> records;
    private long total;
    private long pageNum;
    private long pageSize;
    private Map<String, Long> stats;
    private List<CategoryStat> categoryStats;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CategoryStat implements Serializable {
        private String name;
        private Long id;
        private long count;
    }

    public static <T> ListWithStats<T> of(List<T> records, long total, long pageNum, long pageSize) {
        return new ListWithStats<>(records, total, pageNum, pageSize, null, null);
    }

    public static <T> ListWithStats<T> of(PageResult<T> pageResult) {
        return new ListWithStats<>(pageResult.getRecords(), pageResult.getTotal(),
                pageResult.getPageNum(), pageResult.getPageSize(), null, null);
    }

    public ListWithStats<T> stats(Map<String, Long> stats) {
        this.stats = stats;
        return this;
    }

    public ListWithStats<T> categoryStats(List<CategoryStat> categoryStats) {
        this.categoryStats = categoryStats;
        return this;
    }
}
