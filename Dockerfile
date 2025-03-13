# 构建阶段
FROM node:16 as build-stage

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制项目文件
COPY . .

# 构建应用
RUN npm run build

# 生产阶段
FROM nginx:stable-alpine as production-stage

# 将构建好的文件复制到nginx服务器中
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制示例JSON文件到正确的位置
COPY 1.json /usr/share/nginx/html/

# 暴露80端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
