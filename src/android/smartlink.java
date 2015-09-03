package com.moyang.smartlink;

import com.hiflying.smartlink.OnSmartLinkListener;
import com.hiflying.smartlink.SmartLinkedModule;
import com.hiflying.smartlink.v3.SnifferSmartLinker;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by chendongdong on 15/8/25.
 */
public class smartlink extends CordovaPlugin implements OnSmartLinkListener {

    private static final String TAG = "CustomizedActivity";
    private CallbackContext SmartLinkerallbackContext;
    private Context context;
    protected SnifferSmartLinker mSnifferSmartLinker;
    private boolean mIsConncting = false;
    private BroadcastReceiver mWifiChangedReceiver;


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // your init code here
        context = cordova.getActivity().getApplicationContext();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getSSid")) {
            this.getSSid(callbackContext);
            return true;
        }
        if(action.equals("startSmartLink")){
            this.startSmartLink(callbackContext,args.getString(0),args.getString(1));
            return true;
        }
        return false;
    }

    private void getSSid(CallbackContext callbackContext) {

        WifiManager wm = (WifiManager) context.getSystemService(context.WIFI_SERVICE);
        if (wm != null) {
            WifiInfo wi = wm.getConnectionInfo();
            if (wi != null) {
                String ssid = wi.getSSID();
                if (ssid.length() > 2 && ssid.startsWith("\"") && ssid.endsWith("\"")) {
                    callbackContext.success(ssid.substring(1, ssid.length() - 1));
                } else {
                    callbackContext.error("ssid is empty");
                }
            }
        }
        callbackContext.error("ssid is empty");
    }

    private void startSmartLink(CallbackContext callbackContext,String ssid,String pwd){
        Log.w(TAG, String.format("ssid:%s,pwd:%s", ssid,pwd));
        //设置要配置的ssid 和pswd
        try {
            mSnifferSmartLinker = SnifferSmartLinker.getInstence();
            SmartLinkerallbackContext=callbackContext;

            mSnifferSmartLinker.setOnSmartLinkListener(smartlink.this);
            //开始 smartLink
            mSnifferSmartLinker.start(context, pwd, ssid);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            callbackContext.error(e.getMessage());
        }
    }
    
    @Override
    public void onLinked(SmartLinkedModule smartLinkedModule) {
        Log.w(TAG, "onLinked");
        // TODO Auto-generated method stub
        JSONObject json = new JSONObject();
        try {
            json.put("Mac",smartLinkedModule.getMac());
            json.put("Mid",smartLinkedModule.getMid());
            json.put("ModuleIPc",smartLinkedModule.getModuleIP());
            json.put("Info",smartLinkedModule.toString());
            Log.w(TAG,json.toString());
        } catch (JSONException e) {
            SmartLinkerallbackContext.error(e.getMessage());
        }
        SmartLinkerallbackContext.success(json);
    }

    @Override
    public void onCompleted() {
        Log.w(TAG, "onCompleted");
        JSONObject json=new JSONObject();
        try {
            json.put("success","onCompleted");
        } catch (JSONException e) {
            SmartLinkerallbackContext.error(e.getMessage());
        }
        SmartLinkerallbackContext.success(json);
    }

    @Override
    public void onTimeOut() {
        Log.w(TAG, "onTimeOut");
        JSONObject json=new JSONObject();
        try {
            json.put("error","onTimeOut");
        } catch (JSONException e) {
            SmartLinkerallbackContext.error(e.getMessage());
        }
        SmartLinkerallbackContext.error(json);
    }
}
