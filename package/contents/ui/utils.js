/*
	SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

	SPDX-License-Identifier: GPL-3.0-or-later
*/

.pragma library

function parseEventsJson(jsonRaw) {
    if (!jsonRaw || jsonRaw.trim() === "" || jsonRaw === "[]") {
        return [];
    }

    try {
        let parsed = JSON.parse(jsonRaw);
        if (Array.isArray(parsed)) {
            return parsed.map(event => ({
                title : String(event.title || "").trim(),
                date : String(event.date || "").trim()
            }));
        }
    } catch (e) {
        console.error("Utils: Failed to parse events JSON:", e);
    }
    return [];
}

function sortEvents(eventArray) {
    return eventArray.sort((a, b) => new Date(a.date) - new Date(b.date));
}

function calculateDaysSince(eventArray) {
    let today = new Date();
    today.setHours(0, 0, 0, 0);

    return eventArray.map(item => {
        let eventDate = Date.fromLocaleString(Qt.locale(), item.date, "yyyy-MM-dd");
        eventDate.setHours(0, 0, 0, 0);

        let delta = today - eventDate;
        let deltaDays = Math.floor(delta / (1000 * 60 * 60 * 24));
        let formattedDate = eventDate.toLocaleDateString(Qt.locale(), "MMMM dd, yyyy");

        return {title : item.title, date : formattedDate, days : deltaDays};
    });
}

function getMillisecondsUntilMidnight() {
    let now = new Date();
    let midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 0);
    let delta = midnight.getTime() - now.getTime();

    // 1 second safety
    return Math.max(diff, 1000);
}

