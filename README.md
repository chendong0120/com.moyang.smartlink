汉枫配对:

1.getSSid();
    返回String 连接路由的ssid
    cordova.plugins.smartlink.getSSid(successCallback,errorCallback);

2.startSmartLink(ssid,pwd,successCallback,errorCallback);
      var successCallback = function (result) {
            console.log("-----successCallback------ret----\n",
                "Mac:"+result.Mac
                +"Mid"+result.Mid
                +"ModuleIPc"+result.ModuleIPc
                +"Info"+result.Info
                );
        };
        var errorCallback = function (err) {
            console.log(err.error);
        };
   cordova.plugins.smartlink.startSmartLink(wifissid,wifikey,successCallback,errorCallback);