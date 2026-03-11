export default {
  table: {
    apiSetting: {
      // 当前页的字段名
      pageField: 'pageNum',
      // 每页数量字段名
      sizeField: 'pageSize',
      // 接口返回的数据字段名
      listField: 'records',
      // 接口返回总页数字段名
      totalField: 'total',
    },
    //默认分页数量
    defaultPageSize: 15,
    //可切换每页数量集合
    pageSizes: [10, 15, 20, 30, 50],
  },
  upload: {
    //考虑接口规范不同
    apiSetting: {
      // 集合字段名
      infoField: 'data',
      // 图片地址字段名
      imgField: 'data',
    },
    //最大上传图片大小 (MB)
    maxSize: 2,
    //图片上传类型
    fileType: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/webp'],
  },
};
