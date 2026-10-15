/*
	SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

	SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

import "utils.js" as Utils

Kirigami.ScrollablePage {
    id: configRoot

    property string newTitle: ""
    property string newDate: ""
    property string errorMessage: ""
    property bool fieldsValid: false

    ListModel {
        id: localEventsModel
    }

    function loadConfigEvents() {
        let rawJson = Plasmoid.configuration.eventsJson;
        let events = Utils.parseEventsJson(rawJson);

        localEventsModel.clear();
        for (let event of events) {
            localEventsModel.append(event);
        }
    }

    Component.onCompleted: loadConfigEvents()

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        width: parent.width

        Kirigami.Heading {
            text: i18n("Add events")
            level: 4
            Layout.leftMargin: Kirigami.Units.largeSpacing
        }

        Kirigami.FormLayout {
            QQC2.TextField {
                id: labelText
                Kirigami.FormData.label: i18n("Event Title:")
                placeholderText: i18n("e.g., The Best Day")
                text: configRoot.newTitle
                onTextChanged: {
                    configRoot.newTitle = text;
                    configRoot.validateFields();
                }
            }

            QQC2.TextField {
                id: dateField
                Kirigami.FormData.label: i18n("Date (YYYY-MM-DD):")
                placeholderText: "2023-12-17"
                text: configRoot.newDate
                onTextChanged: {
                    configRoot.newDate = text;
                    configRoot.validateFields();
                }
            }

            Kirigami.InlineMessage {
                Layout.fillWidth: true
                type: Kirigami.MessageType.Error
                text: configRoot.errorMessage
                visible: configRoot.errorMessage !== ""
            }

            QQC2.Button {
                text: i18n("Add Event")
                icon.name: "list-add"
                enabled: configRoot.fieldsValid
                onClicked: configRoot.commitEvent()
            }
        }

        Kirigami.Heading {
            text: i18n("Current Events (%1)", localEventsModel.count)
            level: 3
            visible: localEventsModel.count > 0
            Layout.leftMargin: Kirigami.Units.largeSpacing
        }

        ListView {
            id: eventsListView
            Layout.fillWidth: true
            implicitHeight: contentHeight
            model: localEventsModel
            interactive: false
            spacing: Kirigami.Units.smallSpacing

            delegate: Kirigami.AbstractCard {
                id: itemDelegate
                width: eventsListView.width

                required property string title
                required property string date
                required property int index

                contentItem: RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    QQC2.Label {
                        text: itemDelegate.title
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    QQC2.Label {
                        text: itemDelegate.date
                        opacity: 0.6
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        display: QQC2.AbstractButton.IconOnly
                        Layout.alignment: Qt.AlignVCenter
                        QQC2.ToolTip.text: i18n("Delete Event")
                        onClicked: configRoot.deleteEvent(itemDelegate.index)
                    }
                }
            }
        }
    }

    function validateFields() {
        const title = configRoot.newTitle.trim();
        const inputDate = configRoot.newDate.trim();

        if (title === "") {
			configRoot.errorMessage = "";
            configRoot.fieldsValid = false;
            return;
        }

        if (inputDate === "" || inputDate.length < 10) {
            configRoot.errorMessage = "";
            configRoot.fieldsValid = false;
            return;
        }

        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(configRoot.newDate)) {
            configRoot.errorMessage = i18n("Format must be exactly YYYY-MM-DD");
            configRoot.fieldsValid = false;
            return;
        }
        const parsedDate = Date.fromLocaleString(Qt.locale(), configRoot.newDate, "yyyy-MM-dd");
        if (isNaN(parsedDate)) {
            configRoot.errorMessage = i18n("Invalid calendar date");
            return;
        }

        configRoot.errorMessage = "";
        configRoot.fieldsValid = true;
    }

    function commitEvent() {
        let rawJson = Plasmoid.configuration.eventsJson;
        let currentEvents = Utils.parseEventsJson(rawJson);
        currentEvents.push({
            "title": String(configRoot.newTitle).trim(),
            "date": String(configRoot.newDate).trim()
        });

        let sortedEvents = Utils.sortEvents(currentEvents);
        Plasmoid.configuration.eventsJson = JSON.stringify(sortedEvents);
        configRoot.newTitle = "";
        configRoot.newDate = "";
        dateField.text = "";
        configRoot.loadConfigEvents();
    }

    function deleteEvent(targetIndex) {
        let rawJson = Plasmoid.configuration.eventsJson;
        let currentEvents = Utils.parseEventsJson(rawJson);
        if (targetIndex >= 0 && targetIndex < currentEvents.length) {
            currentEvents.splice(targetIndex, 1);
            Plasmoid.configuration.eventsJson = JSON.stringify(currentEvents);
            configRoot.loadConfigEvents();
        }
    }
}
