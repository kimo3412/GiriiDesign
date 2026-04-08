package com.designstudio.statistics.service;

import com.designstudio.statistics.controller.StatisticsController;

/**
 * 数据统计 Service
 */
public interface StatisticsService {

    StatisticsController.DashboardVO getDashboard();
}
