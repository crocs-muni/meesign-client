# Extra steps for installation on macOS:

1. Change --parent to -p in generate keyse bash script

2. Before running the MeeSign server with cargo run, make sure to install protobuf with:

   ``` bash
    brew install protobuf
   ```


3. Since macOS, does not automatically run the flutterCI, we have to do it manually.
   Open the flutter-ci.yml and search for step called "Build native libs for macOS".
   Before you run the commands in that step, you also need to add apple-darwin targets to rustup:

   ``` bash
   rustup target add x86_64-apple-darwin
   ```

    after that, you can run all the commands in the step, eg:
    
    ``` bash
    cd meesign_native/native/meesign-crypto/
            cargo build --release --target x86_64-apple-darwin
            cargo build --release --target aarch64-apple-darwin
            lipo -create -output libmeesign_crypto.dylib \
              target/x86_64-apple-darwin/release/libmeesign_crypto.dylib \
              target/aarch64-apple-darwin/release/libmeesign_crypto.dylib
    ```

4. By running the above commands, you will generate a libmeesign_crypto.dylib file in the
   native/meesign-crypto directory. This file needs to be moved to the correct build folder
   in the MeeSign client. You can easily find the correct path by trying to login with a new
   device in the MeeSign client, which at this point will throw an error saying that the
   libmeesign_crypto.dylib is missing and that you should move it to a specific path.
   Thats the path we are looking for. In my case it was:
   `/Users/.../MeeSign/meesign-client/build/macos/Build/Products/Debug/meesign_client.app/Contents/Frameworks/FlutterMacOS.framework/Versions/A/libmeesign_crypto.dylib`

