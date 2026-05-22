package com.designstudio;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 独立设计师工作室生产流程管理系统 - 主启动类
 */
@SpringBootApplication
public class DesignStudioApplication {

    public static void main(String[] args) {
        SpringApplication.run(DesignStudioApplication.class, args);
    }

}


// Todo
// 1.库存在支付尾款被消耗记录没有存记录
// 2.小程序的订单页面调整一下tab顺序