// 创建服务器
const express = require('express');
const app = express();

// 配置 app 级中间件
const bodyParser = require('body-parser');
const morgan = require('morgan');
const mongoose = require('mongoose');
const passport = require('passport');

app.use(passport.initialize()); // 必须先初始化 passport 容器
app.use(morgan('dev')); // 日志管理
app.use(bodyParser.urlencoded({extended: false})); // 解析表单类型的请求数据
app.use(bodyParser.json()); // 解析 json 类型的请求数据

// 配置路由

// // 顶级路由
app.get('/', (req, res) => {
  res.send({message: 'ok, you got it'});
});

// // 次级路由
app.use('/api', require('./routes/users'));

// 连接数据库
const config = require('./config');
mongoose.Promise = global.Promise; // 使用 node 默认的 promise
mongoose.connect(config.database); // 连接数据库

// 开始监听
const port = process.env.PORT || 8080;
app.listen(8080, () => {
  console.log('Listening on port: ' + port);
});
