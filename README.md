# 炉火餐饮系统iPad点餐端

## 如何使用

iPad点餐端需要连接局域网内的Web Services才能正常工作，这一块的代码不在我这里，因此无法开源。但在实现iPad点餐端的时候，由于客户是界面效果优先的思维，为了减少需求沟通过程中导致的理解偏差，我先实现了可以脱机运行的UI体验版，使用一些测试数据，供客户体验App的整个交互流程，提出修改意见，在修正后再接的后端。因此，在没有后端的情况下，也可以通过UI体验版来使用iPad点餐端。

打开UI体验版的方法：将`SFCommonHeader.h`中的`SF_UI_TEST`宏打开重新运行即可。在进行会员登录时，用户名与密码随意输入字符都能进入会员界面（但不能为空）。

## 一些说明

### 界面相关

- 由于界面不算复杂，因此UI的构建基本上使用的是Interface Builder。
- 由于项目需求的原因，只运行在iPad上，因此并没有使用AutoLayout与SizeClass，也不支持横屏。

### 网络相关

- Web Services是.NET实现的SOAP风格（看到`SFCommandHeader.h`中`http://192.168.1.2/webservice.asmx`就知道啦），并不是REST风格的。由于iOS中SOAP的库不太好找，这里使用的是HTTP Method的方式，将数据打包成JSON格式（为了方便将JSON转成Object），塞到SOAP返回的XML中，因此需要将数据解析两次，看起来怪怪的。
- 由于是在项目后期接入的后端，有些赶工期，网络处理部分并没有好好设计，没有抽出网络模块，导致网络通信同业务逻辑之间并没有很好的解耦，如果想将Web Services从SOAP更换成REST，并不能很方便的切换。关于网络相关的架构设计，可以参考[田伟宇](http://weibo.com/casatwy)大神的[iOS应用架构谈 网络层设计方案](http://casatwy.com/iosying-yong-jia-gou-tan-wang-luo-ceng-she-ji-fang-an.html)。
