const router = require('express').Router();
const User = require('../models/user');
const jwt = require('jsonwebtoken');
const config = require('../config');
const passport = require('passport');

require('../passport')(passport);

/**
 * 使用 router 注册的都是 次级路由
 */

// 注册
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

// 获取 token
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

    user.comparePassword(req.body.password, function(err, isMatched) {
      if (!err && isMatched) {
        const token = jwt.sign({name: user.name}, config.secret, {expiresIn: 1000});
        user.token = token;
        user.save(function(err) {
          if (err) {
            return res.send(err);
          }

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


// 获取用户信息
router.get('/user/info', passport.authenticate('bearer', {session: false}), function(req, res) {
  res.send({
    username: req.user.name,
  });
});

module.exports = router;
