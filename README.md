# MyLoginDemo

## 运行方法

### Node 端

1. 将项目 clone 下来

    ```sh
    git clone https://github.com/Monsoir/iOS-LoginDemo-Nodejs.git
    ```
    
2. 安装依赖

    在 📁NodePart 中运行命令

    ```sh
    npm install
    ```

3. 安装并启动 Mongodb 服务

    - `brew install mongodb`
    - 推荐使用自定义路径创建数据库文件

        ```sh
        mongod --dbpath <parentPath>/data/db
        ```

4. 开启 node 服务

    ```sh
    npm start
    ```


### iOS 端

项目位于 iOSPart 中，使用 Xcode 打开 LoginDemo.xcodeproj

## Other

关于 Node 端开发过程中的记录 [👉 这里](./notes.md)

## TODOs

- 密码加密传输


