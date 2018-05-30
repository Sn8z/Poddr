# Material design icons

using bower 
```
bower install material-design-icons-iconfont --save
```

using npm
```
npm install material-design-icons-iconfont --save
```

---------------------

This repository is a *fork* of the [original repository](https://github.com/google/material-design-icons) Google published.

the only difference - It created to be **developer friendly** (add dependency in bower / npm as fast as possible)

### What's the need?

In the [original repository](https://github.com/google/material-design-icons) when you checkout / using npm install / bower install / ... 

there are many (many) source svg files that you receive as well. **These file are irrelevant and cause congestion** (especially when using in CI systems)

so by removing all files and keeping only the  `iconfont` directory (contains the compiled font and css files for use) - we get better usage experience, and better **developer experience**.


![image](https://cloud.githubusercontent.com/assets/1287098/14408314/09487f1e-fef8-11e5-83e3-d54438a633b8.png)


### Dear Google,

Thanks for the iconfont. Please kindly rethink about the usability
