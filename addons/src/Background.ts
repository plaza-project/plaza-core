declare const browser;

import * as PlazaApi from "./PlazaApi";

browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.command === "addMonitor") {
        const token = message.token;
        const payload = message.message;
        const username = message.username;

        PlazaApi.send_xpath_monitor(username, token, payload);
    }
});