/**
 * Created by chendongdong on 15/8/25.
 */
var exec = require('cordova/exec');

exports.getSSid = function (success, error) {
    exec(success, error, "smartlink", "getSSid", []);
};
exports.startSmartLink = function (ssid, wifikey,success, error) {
    exec(success, error, "smartlink", "startSmartLink", [ssid, wifikey]);
};
