import { NativeModules, NativeEventEmitter } from "react-native";

const { RnWebim } = NativeModules;

const eventEmitter = new NativeEventEmitter(RnWebim);

const EVENTS = {
  MESSAGE_ADDED: "messageAdded",
  MESSAGE_REMOVED: "messageRemoved",
  MESSAGE_CHANGED: "messageChanged",
  ALL_MESSAGES_REMOVED: "allMessagesRemoved",
};

const onEvent = (event, callback) => {
  eventEmitter.addListener(event, callback);
  return () => eventEmitter.removeListener(event, callback);
};

const resume = (params = {}) => {
  return RnWebim.resume({
    ...params,
    userFields: params.userFields ? JSON.stringify(params.userFields) : null,
  });
};

const pause = () => {
  return RnWebim.pause();
};

const destroy = (clearData = false) => {
  return RnWebim.destroy(clearData);
};

const sendMessage = (text = "") => {
  return RnWebim.sendMessage(text);
};

const getLastMessages = (maxCount = 10) => {
  return RnWebim.getLastMessages(maxCount);
};

const getNextMessages = (maxCount = 10) => {
  return RnWebim.getLastMessages(maxCount);
};

const sendFileMessage = (fileUrl, mimeType, fileName, extension) => {
  return RnWebim.sendFileMessage(fileUrl, mimeType, fileName, extension);
};

export default {
  sendFileMessage,
  resume,
  pause,
  destroy,
  sendMessage,
  getLastMessages,
  getNextMessages,
  EVENTS,
  onEvent,
};
