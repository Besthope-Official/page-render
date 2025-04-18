# 构建阶段
FROM node:18 as build-stage

# 设置工作目录
WORKDIR /app

# 设置yarn镜像源
RUN yarn config set registry https://registry.npmmirror.com/

# 复制package.json和yarn.lock
COPY package.json yarn.lock* ./

# 安装依赖
RUN yarn install

# 复制项目文件
COPY . .

# 构建应用
RUN yarn build

# 生产阶段
FROM nginx:stable-alpine as production-stage

# 将构建好的文件复制到nginx服务器中
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制示例JSON文件到正确的位置
COPY --from=build-stage /app/public/1.json /usr/share/nginx/html/

# 暴露80端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
