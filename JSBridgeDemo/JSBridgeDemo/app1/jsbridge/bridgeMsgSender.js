import bridgeCore from './bridgeCore.js';

class BridgeMsgSender {
    showMsg(data, callback) {
        console.log('data');
        // bridge.invoke('showMsg', {"msg": data}, callback);
    }
    navigate(data, callback) {
        // bridge.invoke('navigate',data, callback);
    }
    request(data, callback) {
        // bridge.invoke('request', data, callback);
    }
}

const bridgeMsgSender = new BridgeMsgSender();
export default bridgeMsgSender;