class BridgeCore {
    // 存放回调方法
    _callbackMap: Map<string, any> = new Map();
    // 事件监听
    _nativeMsgListener: Map<string, Array<any>> = new Map();

    // 调用native的方法
    invoke(action: string, data: any, callback: any) {
        var callbackId = ""
        if(this._isvalid(action)) {
            callbackId = this._generateUUID();
            this._callbackMap[callbackId] = callback;
        }
        let msg = {
            action,
            data,
            callbackId,
        };
        this._sendMsg(msg);
    }

    // 告诉native处理回调
    nativeHandleResponse(data: any, callbackId: string) {
        if(callbackId != undefined || callbackId != null) {
            let msg = {
                action: 'handleH5Response',
                data: data,
                callbackId: callbackId
            };
            this._sendMsg(msg);
        }
    }

    // 处理native侧发送过来的消息
    handleNativeMsg(msg: any) {
        if (msg.action == "handleNativeResponse") {
            this.handleNativeResponse(msg);
            return;
        }
        let listeners = this._nativeMsgListener[msg.action] || [];
        listeners.array.forEach((callback: any) => {
            if (this._isvalid(callback)) {
                callback(msg.data);
            }
        });
    }

    // 添加原生事件消息监听
    addNativeMsgListenner(action: string, callback: any) {
        let callbacks = this._nativeMsgListener[action] || [];
        callbacks.push(callback);
    }

    // 移除指定原生事件监听
    removeNativeMsgListener(action: string) {
        this._nativeMsgListener.delete(action);
    }

    // 移除所有原生事件监听
    removeAllNativeMsgListener(){
        this._nativeMsgListener.clear();
    }
    
    // 回调处理
    handleNativeResponse(msg: any) {
        let callbackFunction = this._callbackMap[msg.callbackId];
        if (this._isvalid(callbackFunction)) {
            this._callbackMap.delete(msg.callbackId);
            callbackFunction(msg.data);
        }
    }

     // 生成callbackId
     _generateUUID() {
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

    // 发送消息
    _sendMsg(msg: { action: string; data: any; callbackId: string; }) {
        // TODO: 判断不同平台，目前只处理iOS
        window.webkit.messageHandlers.JSBridge.postMessage(msg);
    }

    _isvalid(method: string) {
        return (method != undefined && method != null && typeof method === 'function');
    }
}

const bridgeCore = new BridgeCore();
export default bridgeCore;