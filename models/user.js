const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const bcrypt = require('bcrypt');

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

// 方法钩子，保存前的操作
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

// 为 schema 添加自己的方法
UserSchema.methods.comparePassword = function(password, callback) {
    bcrypt.compare(password, this.password, function(err, isMatch) {
        if (err) {
            return callback(err);
        }

        callback(null, isMatch);
    });
};

// 导出
module.exports = mongoose.model('User', UserSchema);
