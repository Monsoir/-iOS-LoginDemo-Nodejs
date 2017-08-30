# 使用 Node.js 搭建后台

## 开发环境

- 系统环境：macOS 10.12.6
- Node v8.1.0
- 开发工具：Visual Studio Code

## 安装 Mongodb

由于用到的数据库为 Mongodb, 因此我们需要先安装 Mongodb

### 使用 brew 安装 mongodb

```sh
brew install mongodb
```

### 设置数据库路径

Mongodb 安装完成后，直接运行导致异常，数据库开启失败。因为直接运行时，默认读取的是 `/data/db` 这个文件，但一般情况下，Mac 上是不存在这个文件，因此，我们需要先创建这个数据库文件，而创建和使用这个数据库文件的方法有二

- 创建 `/data/db` 文件
- 创建自定义的数据库文件

#### 创建和使用 /data/db 默认文件

```sh
mkdir -p /data/db # 创建文件
chown `id -u` /data/db # 赋予权限
```
Note 1 [^1]

#### 创建和使用自定义的数据库文件

```sh
mongod --dbpath dir_name
```

同时，可以从命令行中连接 mongodb, 在开启 mongodb 服务后，

```sh
mongo
```

### Mongodb GUI 管理程序

[Robo 3T](https://robomongo.org)

## 使用 Node 开始搭建

### 总体概览

#### 包含以下功能

- 注册
- 获取 token
- 通过 token 获取用户信息

#### 路由设置

路由 | 请求方法 | 作用
--- | --- | ---
localhost:8080/ | GET | 主页，没什么东西
localhost:8080/api/signup | POST | 注册
localhost:8080/api/user/accesstoken | POST | 获取 token
localhost:8080/api/user/info | POST | 根据 token 获取用户信息

#### 项目目录结构

![-w300](https://ws2.sinaimg.cn/large/006tNc79gy1fj1q9s12zcj30m00j8gmt.jpg)

- /models 存放数据模型
- /routes 存放路由文件
- app.js 项目启动入口
- config.js 项目的一些配置
- passport.js token 配置校验策略

### 依赖安装

项目使用的服务器是 express, 我们安装 express generator, 用过它，快速生成一个 express 项目的框架 [^2]

```sh
npm install -g express-generator
```

先安装 express 框架中自带的依赖

```sh
npm install
```

再安装我们项目中需要的依赖，依赖有：

依赖名称 | 备注
--- | ---
[body-parser](https://github.com/expressjs/body-parser) | 解析请求 body 中的字段
[morgan](https://github.com/expressjs/morgan) | 命令行 log 输出
[mongoose](http://mongoosejs.com) | 与 Mongodb 交互
[jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) | 生成 token
[bcrypt](https://www.npmjs.com/package/bcrypt) | 用于对密码进行加密和校验
[passport](http://passportjs.org) | 权限校验库
[passport-http-bearer](https://github.com/jaredhanson/passport-http-bearer) | passport 中权限校验的一个具体策略

安装

```sh
npm install -S xxx
```

最后，将 package.json 中的关于启动脚本修改一下，将 `scripts` 内容改为

```json
"scripts": {
    "start": "node ./app.js"
},
```

这样，当我们运行 `npm start` 是，自动运行到 app.js

### config.js

在这个文件中，我们写入一些项目中用到的一些配置

```js
module.exports = {
    secret: 'ASecretKey',
    database: 'mongodb://127.0.0.1:27017/test', // 数据库地址
};
```

- secret 是等下生成 token 时使用到的
- database 是 mongodb 服务开启时，terminal 中显示正在监听的地址

### app.js

先通过编写 app.js 了解整个项目的大致流程

1. 创建服务器
2. 配置 app 级中间件 [^3]
3. 配置路由
4. 配置和连接数据库
5. 开始监听

#### 创建服务器

Express 是 Node.js 的一个服务器程序框架，创建一个 Express 程序比较简单

```js
// 创建服务器
const express = require('express');
const app = express();
```

#### 配置 app 级中间件

```js
// 配置 app 级中间件
const bodyParser = require('body-parser');
const morgan = require('morgan');
const mongoose = require('mongoose');
const passport = require('passport');

app.use(passport.initialize()); // 必须先初始化 passport 容器
app.use(morgan('dev')); // 日志管理
app.use(bodyParser.urlencoded({extended: false})); // 解析表单类型的请求数据
app.use(bodyParser.json()); // 解析 json 类型的请求数据
```

- 从本质上来说，一个 Express 应用就是在调用各种中间件
- 中间件绑定方法有两种：
    - app.use()
    - app.METHOD() 这里的 METHOD 指的是 HTTP 方法，GET, POST, DELETE
- 上述中间件的绑定方法就是使用了 `app.use()`, 没有绑定路由，这意味着 app 的每个请求都会执行执行这些中间件
- passport 校验策略需要进行进一步配置才能真正使用，配置步骤在后面叙述

#### 配置路由

```js
// 配置路由

// // 顶级路由
app.get('/', (req, res) => {
  res.send({message: 'ok, you got it'});
});

// // 次级路由
app.use('/api', require('./routes/users'));
```

- 配置路由的过程，实质上也就是配置中间件的过程
- 上述的次级路由意思是，URL 的以 `/api` 开始

#### 配置并连接数据库

```js
// 连接数据库
const config = require('./config');
mongoose.Promise = global.Promise; // 使用 node 默认的 promise
mongoose.connect(config.database); // 连接数据库
```

Note 3 [^4]

#### 开始监听

```js
// 开始监听
const port = process.env.PORT || 8080;
app.listen(8080, () => {
  console.log('Listening on port: ' + port);
});
```

### 模型 /models/user

创建数据模型 User, 在创建的过程中，我们有以下步骤

1. 创建一个 Schema, 对应的就是 model
2. 编写方法钩子，在数据保存前做更多的操作
3. 为 Schema 添加自定义方法
4. 导出这个 Schema

#### 创建 Schema

引入依赖，Schema 依赖于 mongoose

```js
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
```

创建 Schema

```js
// 创建一个新的 schema
const UserSchema = new Schema({
    name: {
        type: String,
        unique: true,
        required: true,
    },
    password: {
        type: String,
        required: true,
    },
    token: {
        type: String,
    },
});
```

新建 Schema 中的参数，每一个对象就对应数据库中的一个值

#### 方法钩子

引入依赖，我们需要将密码加密保存

```js
const bcrypt = require('bcrypt');
```

```js
UserSchema.pre('save', function(next) {
    var user = this;
    if (this.isModified('password') && this.isNew) {
       bcrypt.genSalt(10, function(err, salt) {
           if (err) {
               return next(err);
           }

           // 盐来了，加密
           bcrypt.hash(user.password, salt, function(err, hash) {
               if (err) {
                   return next(err);
               }

               user.password = hash; // 将密码替换为加盐加密后的字符串
               next();
           });
       });
    } else {
        return next();
    }
});
```

- 这个方法会在数据保存之前进行调用，在这个方法中，我们将 User 的密码字段使用密码加密加盐后的字符串来代替，不直接在数据库中保存密码
- 方法的回调函数中，接收一个 `next` 的参数，估计是这个钩子也是通过中间件的形式进行构造，因此，在操作完成后，需要调用 `next()` 参数，否则，这个保存过程将会被挂起
- bcrypt 加密通过 `hash` 来实现

#### 为 Schema 添加自定义方法

```js

// 为 schema 添加自己的方法
UserSchema.methods.comparePassword = function(password, callback) {
    bcrypt.compare(password, this.password, function(err, isMatch) {
        if (err) {
            return callback(err);
        }

        callback(null, isMatch);
    });
};
```

- bcrypt 通过 `compare` 来比较输入的密码是否相同，而不是进行解密

Note 5 [^5]


#### 导出

```js
// 导出
module.exports = mongoose.model('User', UserSchema);
```

- 在此版本的 node 中，还不支持 ES6 的 `export` 和 `import`, 因此使用 `module.exports` 来进行导出

### 配置校验策略

项目所依赖的 passport, 只是一个库，使用的设计模式为 策略模式，并没有实现具体的校验策略，需要我们手动传出使用的具体策略

而项目中的另一个依赖，passport-http-bearer 就是一个具体的校验策略

#### 引入依赖

```js
const passport = require('passport');
const Strategy = require('passport-http-bearer').Strategy;

const User = require('./models/user');
```

- 校验库 passport
- 具体的 bearer 校验策略
- 校验也需要基于数据，因此，我们引入数据模型

#### 开始配置

> Before asking Passport to authenticate a request, the strategy (or strategies) used by an application must be configured.

在使用 passport 对一个请求进行验证之前，验证策略需要实现被配置好

```js
module.exports = (passport) => {
    passport.use(new Strategy(function(token, done) {
        User.findOne({
            token,
        }, function(err, user) {
            if (err) {
                return done(err);
            }

            if (!user) {
                return done(null, false);
            }

            return done(null, user);
        });
    }));
};
```

> Strategies, and their configuration, are supplied via the use() function.

策略和它们的配置，通过 `use()` 方法提供

而在这里，策略的验证思路是，根据请求中的 token 寻找对应的用户


##### 验证回调

在这里，验证回调可是非常有讲究的，回调的函数格式有 3 种

```js
return done(null, user);
```

校验通过，第一个参数为 null，第二参数为用户信息


```js
return done(null, false, {message: "blah blah ..."});
```

校验不通过，第一个参数为 null, 第二个参数为 false，第三个参数可选，额外的信息

```js
return done(err);
```

校验失败，通常是服务器故障

### 路由

根据上面的那个 URL 表，我们还有 3 个路由需要编写，首先，我们先编写好大致的框架

由于其余 3 条路由是挂在在 `/api` 上，我们将使用 Express 中的 Router 类来配置路由

`express.Router` 类可以将路由模块化，配置成可挂载的

```js
const router = require('express').Router();

// 注册
router.post('/signup', function(req, res) {

});

// 获取 token
router.post('/user/accesstoken', function(req, res){

});

// 获取用户信息
router.get('/user/info', passport.authenticate('bearer', {session: false}), function(req, res) {

});

module.exports = router;
```

#### 注册路由

```js
const User = require('../models/user');
```

```js
router.post('/signup', function(req, res) {
  if (!req.body.name || !req.body.password) {
    res.send({
      success: false,
      msg: 'Input username and password',
    });
    return;
  }
  
  const newUser = new User({
    name: req.body.name,
    password: req.body.password,
  });

  newUser.save(function(err) {
    if (err) {
      return res.send({
        success: false,
        msg: 'failed to register',
      });
    }

    return res.send({
      success: true,
      msg: 'succeeded to register',
    });
  });
});
```

- 首先要检验请求的参数是否合法
- 创建一个用户实例，在这个实例上调用 `save()` 进行保存
- 根据保存的结果返回，这个返回需要在回调中进行，因为数据库操作是耗时操作

#### 获取 token

```js
const jwt = require('jsonwebtoken');
```

```js
router.post('/user/accesstoken', function(req, res) {
  User.findOne({
    name: req.body.name,
  }, function(err, user) {
    if (err) {
      throw err;
      return;
    }

    if (!user) {
      return res.send({
        success: false,
        msg: 'failed to identify, user does not exist',
      });
    }

    // 找到了用户
    user.comparePassword(req.body.password, function(err, isMatched) {
      if (!err && isMatched) {
        // 用户输入的密码也对了，然后生成 token
        const token = jwt.sign({name: user.name}, config.secret, {expiresIn: 1000});
        user.token = token;
        user.save(function(err) {
          if (err) {
            return res.send(err);
          }
          // 保存好了
          return res.send({
            success: true,
            msg: 'token generated',
            token: 'Bearer ' + token,
            name: user.name,
          });
        });
      } else {
        return res.send({
          success: false,
          msg: 'wrong password',
        });
      }
    });
  });
});
```

- jsonwebtoken 在这里用于生成签名的加密的 token
- `user.comparePassword` 就是之前在 UserSchema 中自定义的密码校验方法
- 生成 token 后还需要将在数据库中存储起来，留到之后使用

#### 获取用户信息

我们这里简单地返回一个用户名来意思一下

```js
router.get('/user/info', passport.authenticate('bearer', {session: false}), function(req, res) {
  res.send({
    username: req.body.name,
  });
});
```

- 与之前的两个路由函数不同，这个函数在路由和回调之间多了一个验证的方法，这也就是利用中间件来进行验证
- 而当验证成功之后，回调函数的 `req` 参数中将会包含 `user` 数据，而这个 `user` 就是之前配置验证策略时传入的
- 在 `authenticate` 方法中，有个写死的字符串，这个就是用来指定使用的验证策略 bearer
- 同时，注意到，`authenticate` 方法中还有一个 session 的参数，这个参数为 true 时，适用于浏览器的程序，而在支持 RESTful API 的服务器上，可以放心地设置为 false

#### 最后

我们回过头到 app.js 中，在配置验证中间件时

```js
app.use(passport.initialize()); // 必须先初始化 passport 容器
```

如注释所说，在使用 passport 前，必须先调用 `initializer` 对 passport 进行初始化

## References

- [https://segmentfault.com/a/1190000008629632?u=123](https://segmentfault.com/a/1190000008629632?u=123)
- [http://hcysun.me/2015/11/21/Mac下使用brew安装mongodb/](http://hcysun.me/2015/11/21/Mac下使用brew安装mongodb/)

## Todos

- mongoose 中 doc 的概念
- 策略模式
- 免登录功能的实现 token, session
- 检验 token 过期

## Notes

[^1]: mkdir 命令 p 选项：自动创建新文件路径中不存在的 📁
[^2]: 这里通过全局安装，可以重复使用，因为这是项目的最基本的东西，所以通过全局安装
[^3]: Express 中的中间价有 app 级中间件和路由级中间件
[^4]: 至于这里为什么需要 `mongoose.Promise = global.Promise`, 还没有弄清楚，但是不影响大局
[^5]: 在官方文档中，Schema 中并没有找到 `methods` 属性，而是通过 `method` 来实现


