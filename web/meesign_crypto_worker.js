importScripts('./meesign_crypto.js');

console.log('Initializing worker')

const {encrypt, Protocol} = wasm_bindgen;

async function init_worker() {
    // TODO: handle errors
    // TODO: move to meesign_native?
    self.onmessage = async event => {
        await wasm_bindgen('./meesign_crypto_bg.wasm');

        let cmd = event.data;
        console.log(cmd);

        let resp = {};
        resp.id = cmd.id;

        let proto;

        switch (cmd.function) {
          case 'encrypt':
            resp.data = encrypt(cmd.msg, cmd.key);
            break;
            case 'keygen':
            proto = Protocol.keygen(cmd.proto);
            resp.data = proto.serialize();
            break;
          case 'init':
            proto = Protocol.init(cmd.proto, cmd.ctx);
            resp.ctx = proto.serialize();
            break;
          case 'advance':
            proto = Protocol.deserialize(cmd.ctx);
            resp.data = proto.advance(cmd.data);
            resp.ctx = proto.serialize();
            break;
          case 'finish':
            proto = Protocol.deserialize(cmd.ctx);
            resp.data = proto.finish();
            break;
        }

        self.postMessage(resp);
    };
};

init_worker();
