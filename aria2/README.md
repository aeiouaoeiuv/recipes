# aria2

源码: [https://github.com/aria2/aria2](https://github.com/aria2/aria2)

```
./configure --prefix=${HOME}/.local
make && make install
```

# 配置

```
mkdir -p ${HOME}/.local/etc
touch ${HOME}/.local/etc/aria2.session
cp -f aria2.conf ${HOME}/.local/etc
```

`bt-tracker` list from this site: [https://github.com/ngosang/trackerslist](https://github.com/ngosang/trackerslist)

# 启动

```
aria2c --conf-path=${HOME}/.local/etc/aria2.conf
# -D 是后台运行
```

