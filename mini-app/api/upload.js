import { getApp } from '@dcloudio/uni-app'

const BASE_URL = 'http://localhost:8080'

/**
 * 上传文件到服务器
 * @param {string} filePath - 文件路径
 * @returns {Promise<string>} - 返回文件URL
 */
export const uploadFile = (filePath) => {
  return new Promise((resolve, reject) => {
    uni.uploadFile({
      url: BASE_URL + '/api/v1/upload',
      filePath: filePath,
      name: 'file',
      success: (res) => {
        const data = JSON.parse(res.data)
        if (data.code === 200) {
          resolve(data.data.url)
        } else {
          reject(new Error(data.msg || '上传失败'))
        }
      },
      fail: reject
    })
  })
}

/**
 * 批量上传文件
 * @param {string[]} filePaths - 文件路径数组
 * @returns {Promise<string[]>} - 返回URL数组
 */
export const uploadFiles = async (filePaths) => {
  const urls = []
  for (const path of filePaths) {
    const url = await uploadFile(path)
    urls.push(url)
  }
  return urls
}
