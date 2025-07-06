package com.app4t2.rnwebim;

import java.util.List;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import ru.webim.android.sdk.Webim;
import ru.webim.android.sdk.WebimSession;
import ru.webim.android.sdk.MessageListener;
import ru.webim.android.sdk.Message;
import ru.webim.android.sdk.MessageTracker;
import ru.webim.android.sdk.WebimLog;

public class RnWebimModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    private WebimSession session;
    private MessageTracker tracker;
    private Utils utils;
    private WebimMessageListener messageListener;

    public RnWebimModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.utils = new Utils(this.reactContext);
        this.messageListener = new WebimMessageListener(this.utils);
    }

    @Override
    public String getName() {
        return "RnWebim";
    }


    private void build(String accountName, String location, String userFields) {
        Webim.SessionBuilder builder = Webim.newSessionBuilder().setContext(this.reactContext)
                .setAccountName(accountName).setLocation(location)
                .setLogger(new WebimLog() {
                    @Override
                    public void log(String log) {
                        Log.i("WEBIM LOG", log);
                    }
                }, Webim.SessionBuilder.WebimLogVerbosityLevel.VERBOSE);
        if (userFields != null) {
            builder.setVisitorFieldsJson(userFields);
        }
        session = builder.build();
    }

    @ReactMethod
    public void resume(ReadableMap builderData, Promise promise) {

        String accountName = builderData.getString("accountName");
        String location = builderData.getString("location");
        String userFields = builderData.getString("userFields");

        if (session == null) {
            build(accountName, location, userFields);
        }

        if (session == null) {
            promise.reject("errorcode","Unable to build session");
        }
        session.resume();
        session.getStream().startChat();
        session.getStream().setChatRead();
        tracker = session.getStream().newMessageTracker(this.messageListener);
        promise.resolve("success");

    }

    @ReactMethod
    public void pause(Promise promise) {
        if (session == null) {
            promise.reject("errorcode","Unable to find session");
        }
        session.pause();
        promise.resolve("success");

    }

    @ReactMethod
    public void destroy(Boolean clearData, Promise promise) {
        if (session != null) {
            session.getStream().closeChat();
            tracker.destroy();
            if (clearData) {
                session.destroyWithClearVisitorData();
            } else {
                session.destroy();
            }
            session = null;
        }
        promise.resolve(null);
    }

    @ReactMethod
    public void sendMessage(String message, Promise promise) {
        try {
           Message.Id messageId = session.getStream().sendMessage(message);
            Log.i("WEBIM LOG DEBUG", "sendMessage messageid");
            Log.i("WEBIM LOG DEBUG", messageId.toString());
            promise.resolve("success");
        } catch (Exception e) {
            Log.i("WEBIM LOG DEBUG", "Send message error");
            Log.i("WEBIM LOG DEBUG", e.toString());
            promise.reject("errorcode", "Send message error", e);
        }

    }

    @ReactMethod
    public void sendFile(String fileUri, String name, String mimeType, Promise promise) {
        try {
            // Validate file existence
            String filePath = fileUri.startsWith("file://") ? fileUri.substring(7) : fileUri;
            File file = new File(filePath);
            if (!file.exists() || !file.isFile()) {
                throw new IOException("File not found or is not a file");
            }

            // Validate file size (e.g., 10MB limit)
            long fileSize = file.length();
            if (fileSize > 10 * 1024 * 1024) {
                throw new IOException("File size exceeded");
            }

            // Validate MIME type
            String[] allowedMimeTypes = {"image/jpeg", "image/png", "application/pdf"};
            boolean isValidMimeType = false;
            for (String allowedType : allowedMimeTypes) {
                if (allowedType.equals(mimeType)) {
                    isValidMimeType = true;
                    break;
                }
            }
            if (!isValidMimeType) {
                throw new IOException("Type not allowed");
            }

            // Read file into byte array
            byte[] fileData = new byte[(int) fileSize];
            try (FileInputStream fis = new FileInputStream(file)) {
                fis.read(fileData);
            }

            // Send file using MessageStream
            session.getStream().send(fileData, name, mimeType, new FileSendingCompletionHandler() {
                @Override
                public void onSuccess() {
                    Log.i("WEBIM LOG DEBUG", "sendFile success");
                    promise.resolve("success");
                }

                @Override
                public void onFailure(Exception e) {
                    Log.i("WEBIM LOG DEBUG", "Send file error");
                    Log.i("WEBIM LOG DEBUG", e.toString());
                    promise.reject("errorcode", "Send file error: " + e.getMessage(), e);
                }
            });
        } catch (Exception e) {
            Log.i("WEBIM LOG DEBUG", "Send file error");
            Log.i("WEBIM LOG DEBUG", e.toString());
            promise.reject("errorcode", "Send file error: " + e.getMessage(), e);
        }
    }


    @ReactMethod
    public void getLastMessages(int limit, final Promise promise) {
        try {
            tracker.getLastMessages(limit, new MessageTracker.GetMessagesCallback() {
                @Override
                public void receive(@NonNull final List< ? extends Message> received) {
                    Log.i("WEBIM LOG DEBUG", "getLastMessages");
                    Log.i("WEBIM LOG DEBUG", received.toString());
                    WritableMap response = Utils.messagesToJson(received);
                    promise.resolve(response);
                }
            });
        } catch (Exception e) {
            Log.i("WEBIM LOG DEBUG", "Error when getting last messages");
            Log.i("WEBIM LOG DEBUG", e.toString());
            promise.reject("errorcide","Error when getting last messages", e);

        }

    }
    @ReactMethod
    public void getNextMessages(int limit, final Promise promise) {
        try {
            tracker.getNextMessages(limit, new MessageTracker.GetMessagesCallback() {
                @Override
                public void receive(@NonNull final List< ? extends Message> received) {
                    Log.i("WEBIM LOG DEBUG", "getNextMessages");
                    Log.i("WEBIM LOG DEBUG", received.toString());
                    WritableMap response = Utils.messagesToJson(received);
                    promise.resolve(response);
                }
            });
        } catch (Exception e) {
            Log.i("WEBIM LOG DEBUG", "Error when getting next messages");
            Log.i("WEBIM LOG DEBUG", e.toString());
            promise.reject("errorcide","Error when getting next messages", e);

        }

    }






}
