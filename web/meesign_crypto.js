let wasm_bindgen;
(function() {
    const __exports = {};
    let script_src;
    if (typeof document !== 'undefined' && document.currentScript !== null) {
        script_src = new URL(document.currentScript.src, location.href).toString();
    }
    let wasm = undefined;

    function addToExternrefTable0(obj) {
        const idx = wasm.__externref_table_alloc();
        wasm.__wbindgen_export_2.set(idx, obj);
        return idx;
    }

    function handleError(f, args) {
        try {
            return f.apply(this, args);
        } catch (e) {
            const idx = addToExternrefTable0(e);
            wasm.__wbindgen_exn_store(idx);
        }
    }

    const cachedTextDecoder = (typeof TextDecoder !== 'undefined' ? new TextDecoder('utf-8', { ignoreBOM: true, fatal: true }) : { decode: () => { throw Error('TextDecoder not available') } } );

    if (typeof TextDecoder !== 'undefined') { cachedTextDecoder.decode(); };

    let cachedUint8ArrayMemory0 = null;

    function getUint8ArrayMemory0() {
        if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
            cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
        }
        return cachedUint8ArrayMemory0;
    }

    function getStringFromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
    }

    function getArrayU8FromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return getUint8ArrayMemory0().subarray(ptr / 1, ptr / 1 + len);
    }

    function isLikeNone(x) {
        return x === undefined || x === null;
    }

    let WASM_VECTOR_LEN = 0;

    function passArray8ToWasm0(arg, malloc) {
        const ptr = malloc(arg.length * 1, 1) >>> 0;
        getUint8ArrayMemory0().set(arg, ptr / 1);
        WASM_VECTOR_LEN = arg.length;
        return ptr;
    }

    function takeFromExternrefTable0(idx) {
        const value = wasm.__wbindgen_export_2.get(idx);
        wasm.__externref_table_dealloc(idx);
        return value;
    }
    /**
     * @param {number} proto_id
     * @param {Uint8Array} certs
     * @param {Uint8Array} pkcs12
     * @param {boolean} with_card
     * @param {number} shares
     * @returns {Uint8Array}
     */
    __exports.wasm_protocol_keygen = function(proto_id, certs, pkcs12, with_card, shares) {
        const ptr0 = passArray8ToWasm0(certs, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(pkcs12, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_protocol_keygen(proto_id, ptr0, len0, ptr1, len1, with_card, shares);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v3;
    };

    /**
     * @param {number} proto_id
     * @param {Uint8Array} group
     * @param {Uint8Array} certs
     * @param {Uint8Array} pkcs12
     * @param {number} shares
     * @returns {Uint8Array}
     */
    __exports.wasm_protocol_init = function(proto_id, group, certs, pkcs12, shares) {
        const ptr0 = passArray8ToWasm0(group, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(certs, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(pkcs12, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_protocol_init(proto_id, ptr0, len0, ptr1, len1, ptr2, len2, shares);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v4 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v4;
    };

    /**
     * @param {Uint8Array} context
     * @param {number} index
     * @param {Uint8Array} data
     * @returns {WasmProtocolData}
     */
    __exports.wasm_protocol_advance = function(context, index, data) {
        const ptr0 = passArray8ToWasm0(context, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_protocol_advance(ptr0, len0, index, ptr1, len1);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return WasmProtocolData.__wrap(ret[0]);
    };

    /**
     * @param {Uint8Array} context
     * @returns {Uint8Array}
     */
    __exports.wasm_protocol_finish = function(context) {
        const ptr0 = passArray8ToWasm0(context, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_protocol_finish(ptr0, len0);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v2;
    };

    const cachedTextEncoder = (typeof TextEncoder !== 'undefined' ? new TextEncoder('utf-8') : { encode: () => { throw Error('TextEncoder not available') } } );

    const encodeString = (typeof cachedTextEncoder.encodeInto === 'function'
        ? function (arg, view) {
        return cachedTextEncoder.encodeInto(arg, view);
    }
        : function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    });

    function passStringToWasm0(arg, malloc, realloc) {

        if (realloc === undefined) {
            const buf = cachedTextEncoder.encode(arg);
            const ptr = malloc(buf.length, 1) >>> 0;
            getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
            WASM_VECTOR_LEN = buf.length;
            return ptr;
        }

        let len = arg.length;
        let ptr = malloc(len, 1) >>> 0;

        const mem = getUint8ArrayMemory0();

        let offset = 0;

        for (; offset < len; offset++) {
            const code = arg.charCodeAt(offset);
            if (code > 0x7F) break;
            mem[ptr + offset] = code;
        }

        if (offset !== len) {
            if (offset !== 0) {
                arg = arg.slice(offset);
            }
            ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
            const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
            const ret = encodeString(arg, view);

            offset += ret.written;
            ptr = realloc(ptr, len, offset, 1) >>> 0;
        }

        WASM_VECTOR_LEN = offset;
        return ptr;
    }
    /**
     * @param {string} name
     * @returns {WasmAuthKey}
     */
    __exports.wasm_auth_keygen = function(name) {
        const ptr0 = passStringToWasm0(name, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_auth_keygen(ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return WasmAuthKey.__wrap(ret[0]);
    };

    /**
     * @param {Uint8Array} key
     * @param {Uint8Array} cert
     * @returns {Uint8Array}
     */
    __exports.wasm_auth_cert_key_to_pkcs12 = function(key, cert) {
        const ptr0 = passArray8ToWasm0(key, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(cert, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_auth_cert_key_to_pkcs12(ptr0, len0, ptr1, len1);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v3;
    };

    /**
     * @param {Uint8Array} message
     * @param {Uint8Array} public_key
     * @returns {Uint8Array}
     */
    __exports.wasm_encrypt = function(message, public_key) {
        const ptr0 = passArray8ToWasm0(message, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(public_key, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wasm_encrypt(ptr0, len0, ptr1, len1);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v3;
    };

    const WasmAuthKeyFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_wasmauthkey_free(ptr >>> 0, 1));
    /**
     * Result of auth keygen, returned as a JS object.
     */
    class WasmAuthKey {

        static __wrap(ptr) {
            ptr = ptr >>> 0;
            const obj = Object.create(WasmAuthKey.prototype);
            obj.__wbg_ptr = ptr;
            WasmAuthKeyFinalization.register(obj, obj.__wbg_ptr, obj);
            return obj;
        }

        __destroy_into_raw() {
            const ptr = this.__wbg_ptr;
            this.__wbg_ptr = 0;
            WasmAuthKeyFinalization.unregister(this);
            return ptr;
        }

        free() {
            const ptr = this.__destroy_into_raw();
            wasm.__wbg_wasmauthkey_free(ptr, 0);
        }
        /**
         * @returns {Uint8Array}
         */
        get key() {
            const ret = wasm.wasmauthkey_key(this.__wbg_ptr);
            var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
            return v1;
        }
        /**
         * @returns {Uint8Array}
         */
        get csr() {
            const ret = wasm.wasmauthkey_csr(this.__wbg_ptr);
            var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
            return v1;
        }
    }
    __exports.WasmAuthKey = WasmAuthKey;

    const WasmProtocolDataFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_wasmprotocoldata_free(ptr >>> 0, 1));
    /**
     * Result of a protocol advance step, returned as a JS object.
     */
    class WasmProtocolData {

        static __wrap(ptr) {
            ptr = ptr >>> 0;
            const obj = Object.create(WasmProtocolData.prototype);
            obj.__wbg_ptr = ptr;
            WasmProtocolDataFinalization.register(obj, obj.__wbg_ptr, obj);
            return obj;
        }

        __destroy_into_raw() {
            const ptr = this.__wbg_ptr;
            this.__wbg_ptr = 0;
            WasmProtocolDataFinalization.unregister(this);
            return ptr;
        }

        free() {
            const ptr = this.__destroy_into_raw();
            wasm.__wbg_wasmprotocoldata_free(ptr, 0);
        }
        /**
         * @returns {Uint8Array}
         */
        get context() {
            const ret = wasm.wasmprotocoldata_context(this.__wbg_ptr);
            var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
            return v1;
        }
        /**
         * @returns {Uint8Array}
         */
        get data() {
            const ret = wasm.wasmprotocoldata_data(this.__wbg_ptr);
            var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
            return v1;
        }
        /**
         * @returns {number}
         */
        get recipient() {
            const ret = wasm.wasmprotocoldata_recipient(this.__wbg_ptr);
            return ret >>> 0;
        }
    }
    __exports.WasmProtocolData = WasmProtocolData;

    async function __wbg_load(module, imports) {
        if (typeof Response === 'function' && module instanceof Response) {
            if (typeof WebAssembly.instantiateStreaming === 'function') {
                try {
                    return await WebAssembly.instantiateStreaming(module, imports);

                } catch (e) {
                    if (module.headers.get('Content-Type') != 'application/wasm') {
                        console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                    } else {
                        throw e;
                    }
                }
            }

            const bytes = await module.arrayBuffer();
            return await WebAssembly.instantiate(bytes, imports);

        } else {
            const instance = await WebAssembly.instantiate(module, imports);

            if (instance instanceof WebAssembly.Instance) {
                return { instance, module };

            } else {
                return instance;
            }
        }
    }

    function __wbg_get_imports() {
        const imports = {};
        imports.wbg = {};
        imports.wbg.__wbg_buffer_609cc3eee51ed158 = function(arg0) {
            const ret = arg0.buffer;
            return ret;
        };
        imports.wbg.__wbg_call_672a4d21634d4a24 = function() { return handleError(function (arg0, arg1) {
            const ret = arg0.call(arg1);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_call_7cccdd69e0791ae2 = function() { return handleError(function (arg0, arg1, arg2) {
            const ret = arg0.call(arg1, arg2);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_crypto_038798f665f985e2 = function(arg0) {
            const ret = arg0.crypto;
            return ret;
        };
        imports.wbg.__wbg_crypto_574e78ad8b13b65f = function(arg0) {
            const ret = arg0.crypto;
            return ret;
        };
        imports.wbg.__wbg_getRandomValues_371e7ade8bd92088 = function(arg0, arg1) {
            arg0.getRandomValues(arg1);
        };
        imports.wbg.__wbg_getRandomValues_7dfe5bd1b67c9ca1 = function(arg0) {
            const ret = arg0.getRandomValues;
            return ret;
        };
        imports.wbg.__wbg_getRandomValues_b8f5dbd5f3995a9e = function() { return handleError(function (arg0, arg1) {
            arg0.getRandomValues(arg1);
        }, arguments) };
        imports.wbg.__wbg_length_a446193dc22c12f8 = function(arg0) {
            const ret = arg0.length;
            return ret;
        };
        imports.wbg.__wbg_msCrypto_a61aeb35a24c1329 = function(arg0) {
            const ret = arg0.msCrypto;
            return ret;
        };
        imports.wbg.__wbg_msCrypto_ff35fce085fab2a3 = function(arg0) {
            const ret = arg0.msCrypto;
            return ret;
        };
        imports.wbg.__wbg_new_a12002a7f91c75be = function(arg0) {
            const ret = new Uint8Array(arg0);
            return ret;
        };
        imports.wbg.__wbg_newnoargs_105ed471475aaf50 = function(arg0, arg1) {
            const ret = new Function(getStringFromWasm0(arg0, arg1));
            return ret;
        };
        imports.wbg.__wbg_newwithbyteoffsetandlength_d97e637ebe145a9a = function(arg0, arg1, arg2) {
            const ret = new Uint8Array(arg0, arg1 >>> 0, arg2 >>> 0);
            return ret;
        };
        imports.wbg.__wbg_newwithlength_a381634e90c276d4 = function(arg0) {
            const ret = new Uint8Array(arg0 >>> 0);
            return ret;
        };
        imports.wbg.__wbg_node_905d3e251edff8a2 = function(arg0) {
            const ret = arg0.node;
            return ret;
        };
        imports.wbg.__wbg_process_dc0fbacc7c1c06f7 = function(arg0) {
            const ret = arg0.process;
            return ret;
        };
        imports.wbg.__wbg_randomFillSync_994ac6d9ade7a695 = function(arg0, arg1, arg2) {
            arg0.randomFillSync(getArrayU8FromWasm0(arg1, arg2));
        };
        imports.wbg.__wbg_randomFillSync_ac0988aba3254290 = function() { return handleError(function (arg0, arg1) {
            arg0.randomFillSync(arg1);
        }, arguments) };
        imports.wbg.__wbg_require_0d6aeaec3c042c88 = function(arg0, arg1, arg2) {
            const ret = arg0.require(getStringFromWasm0(arg1, arg2));
            return ret;
        };
        imports.wbg.__wbg_require_60cc747a6bc5215a = function() { return handleError(function () {
            const ret = module.require;
            return ret;
        }, arguments) };
        imports.wbg.__wbg_self_25aabeb5a7b41685 = function() { return handleError(function () {
            const ret = self.self;
            return ret;
        }, arguments) };
        imports.wbg.__wbg_set_65595bdd868b3009 = function(arg0, arg1, arg2) {
            arg0.set(arg1, arg2 >>> 0);
        };
        imports.wbg.__wbg_static_accessor_GLOBAL_88a902d13a557d07 = function() {
            const ret = typeof global === 'undefined' ? null : global;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_static_accessor_GLOBAL_THIS_56578be7e9f832b0 = function() {
            const ret = typeof globalThis === 'undefined' ? null : globalThis;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_static_accessor_MODULE_ef3aa2eb251158a5 = function() {
            const ret = module;
            return ret;
        };
        imports.wbg.__wbg_static_accessor_SELF_37c5d418e4bf5819 = function() {
            const ret = typeof self === 'undefined' ? null : self;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_static_accessor_WINDOW_5de37043a91a9c40 = function() {
            const ret = typeof window === 'undefined' ? null : window;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_subarray_aa9065fa9dc5df96 = function(arg0, arg1, arg2) {
            const ret = arg0.subarray(arg1 >>> 0, arg2 >>> 0);
            return ret;
        };
        imports.wbg.__wbg_versions_c01dfd4722a88165 = function(arg0) {
            const ret = arg0.versions;
            return ret;
        };
        imports.wbg.__wbindgen_error_new = function(arg0, arg1) {
            const ret = new Error(getStringFromWasm0(arg0, arg1));
            return ret;
        };
        imports.wbg.__wbindgen_init_externref_table = function() {
            const table = wasm.__wbindgen_export_2;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
            ;
        };
        imports.wbg.__wbindgen_is_function = function(arg0) {
            const ret = typeof(arg0) === 'function';
            return ret;
        };
        imports.wbg.__wbindgen_is_object = function(arg0) {
            const val = arg0;
            const ret = typeof(val) === 'object' && val !== null;
            return ret;
        };
        imports.wbg.__wbindgen_is_string = function(arg0) {
            const ret = typeof(arg0) === 'string';
            return ret;
        };
        imports.wbg.__wbindgen_is_undefined = function(arg0) {
            const ret = arg0 === undefined;
            return ret;
        };
        imports.wbg.__wbindgen_memory = function() {
            const ret = wasm.memory;
            return ret;
        };
        imports.wbg.__wbindgen_string_new = function(arg0, arg1) {
            const ret = getStringFromWasm0(arg0, arg1);
            return ret;
        };
        imports.wbg.__wbindgen_throw = function(arg0, arg1) {
            throw new Error(getStringFromWasm0(arg0, arg1));
        };

        return imports;
    }

    function __wbg_init_memory(imports, memory) {

    }

    function __wbg_finalize_init(instance, module) {
        wasm = instance.exports;
        __wbg_init.__wbindgen_wasm_module = module;
        cachedUint8ArrayMemory0 = null;


        wasm.__wbindgen_start();
        return wasm;
    }

    function initSync(module) {
        if (wasm !== undefined) return wasm;


        if (typeof module !== 'undefined') {
            if (Object.getPrototypeOf(module) === Object.prototype) {
                ({module} = module)
            } else {
                console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
            }
        }

        const imports = __wbg_get_imports();

        __wbg_init_memory(imports);

        if (!(module instanceof WebAssembly.Module)) {
            module = new WebAssembly.Module(module);
        }

        const instance = new WebAssembly.Instance(module, imports);

        return __wbg_finalize_init(instance, module);
    }

    async function __wbg_init(module_or_path) {
        if (wasm !== undefined) return wasm;


        if (typeof module_or_path !== 'undefined') {
            if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
                ({module_or_path} = module_or_path)
            } else {
                console.warn('using deprecated parameters for the initialization function; pass a single object instead')
            }
        }

        if (typeof module_or_path === 'undefined' && typeof script_src !== 'undefined') {
            module_or_path = script_src.replace(/\.js$/, '_bg.wasm');
        }
        const imports = __wbg_get_imports();

        if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
            module_or_path = fetch(module_or_path);
        }

        __wbg_init_memory(imports);

        const { instance, module } = await __wbg_load(await module_or_path, imports);

        return __wbg_finalize_init(instance, module);
    }

    wasm_bindgen = Object.assign(__wbg_init, { initSync }, __exports);

})();
