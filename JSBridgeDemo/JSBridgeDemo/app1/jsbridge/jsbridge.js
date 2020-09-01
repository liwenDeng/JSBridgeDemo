
/**
 * Msg: 
 * {
 *     "action": "foo",
 *     "data": {},
 *     "callbackId": "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx",
 * }
 * 
 * 内置 action: nativeHandleResponse
 */
function Bridge() {
    // 存储回调方法
    // key: callbackId, value: function
    this.callBackMaps = new Map();

    // 生成唯一callbackId
    function generateUUID() {
        var d = new Date().getTime();
        if (window.performance && typeof window.performance.now === "function") {
            d += performance.now(); //use high-precision timer if available
        }
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = (d + Math.random() * 16) % 16 | 0;
            d = Math.floor(d / 16);
            return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
        });
        return uuid;
    }
    // 消息发送
    this.sendMsg = function(msg) {
        // TODO: 判断不同平台，目前只处理iOS
        window.webkit.messageHandlers.JSBridge.postMessage(msg);
    }

    // 调用native的方法
    this.callNativeMethod = function(action, data, callback) {
        var callbackId = ""
        if(callback != undefined && callback != null) {
            callbackId = generateUUID();
            this.callBackMaps[callbackId] = callback;
        }
        let msg = {
            "action": action,
            "data": data,
            "callbackId": callbackId
        };
        this.sendMsg(msg);
    }
    // 告诉native处理回调
    this.nativeHandleResponse = function(data, callbackId) {
        if(callbackId != undefined || callbackId != null) {
            let msg = {
                "action": 'handleH5Response',
                "data": data,
                "callbackId": callbackId
            };
            this.sendMsg(msg);
        }
    }
    // 处理native侧发送过来的消息
    this.handleNativeMsg = function(msg) {
        if (msg.action == "handleNativeResponse") {
            this.handleNativeResponse(msg);
            return;
        }
        let functionName = "bridgeMsgListener." + msg.action;
        let func = eval(functionName);
        // 消息转发
        new func(msg);
    }
    // 回调处理
    this.handleNativeResponse = function(msg) {
        let callbackFunction = this.callBackMaps[msg.callbackId];
        if (callbackFunction != undefined && callbackFunction != null) {
            this.callBackMaps.delete(msg.callbackId);
            callbackFunction(msg.data);
        }
    }
}

// 发送h5调用native原生功能的消息
function BridgeMsgSender() {
    this.showMsg = function(data, callback) {
        bridge.callNativeMethod('showMsg', {"msg": data}, callback);
    }
    this.navigate = function(data, callback) {
        bridge.callNativeMethod('navigate',data, callback);
    }
    this.request = function(data, callback) {
        bridge.callNativeMethod('request', data, callback);
    }
}

// 处理native发送到h5的业务功能消息
function BridgeMsgListener() {
    this.h5Toast = function(msg) {
        console.log('h5Toast');
        brdigeSender.showMsg("callH5 toast");
    }
}

var bridge = new Bridge();
var brdigeSender = new BridgeMsgSender();
var bridgeMsgListener = new BridgeMsgListener();