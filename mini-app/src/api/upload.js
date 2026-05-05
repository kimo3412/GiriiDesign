const BASE_URL = 'http://localhost:8081/api'

/**
 * 上传文件到服务器
 * @param {string} filePath - 文件路径
 * @returns {Promise<string>} - 返回文件URL
 */
const uploadTo = (filePath, endpoint, formData = {}) => {
  return new Promise((resolve, reject) => {
    const token = uni.getStorageSync('token')
    
    uni.uploadFile({
      url: BASE_URL + endpoint,
      filePath: filePath,
      name: 'file',
      formData,
      header: {
        'Authorization': token ? `Bearer ${token}` : ''
      },
      success: (res) => {
        let data
        try {
          data = JSON.parse(res.data)
        } catch (error) {
          reject(new Error('上传响应解析失败'))
          return
        }
        if (data.code === 200) {
          resolve(data.data)
        } else {
          reject(new Error(data.msg || '上传失败'))
        }
      },
      fail: reject
    })
  })
}

export const uploadFile = (filePath) => uploadTo(filePath, '/v1/oss/upload')

export const uploadChatFile = (filePath, meta = {}) => uploadTo(filePath, '/v1/oss/chat-upload', meta)

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
