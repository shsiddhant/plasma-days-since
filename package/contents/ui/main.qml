/*
	SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

	SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import "utils.js" as Utils

PlasmoidItem {
    id: root

    switchWidth: Kirigami.Units.gridUnit * 18
    switchHeight: Kirigami.Units.gridUnit * 22

    ListModel {
        id: daysSinceModel
    }

    function refreshData() {
        let rawJson = Plasmoid.configuration.eventsJson;
        let events = Utils.parseEventsJson(rawJson);
        let daysSinceArray = Utils.calculateDaysSince(events);

        daysSinceModel.clear();
        for (let day of daysSinceArray) {
            daysSinceModel.append(day);
        }
    }

    Component.onCompleted: refreshData()

    Connections {
        target: Plasmoid.configuration
        function onEventsJsonChanged() {
            root.refreshData();
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        id: representation
        readonly property bool isOnDesktop: Plasmoid.location === PlasmaCore.Types.Floating

        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 20
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 26

        header: PlasmaExtras.BasicPlasmoidHeading {
            visible: !representation.isOnDesktop
            height: visible ? implicitHeight : 0
        }

        contentItem: PC.ScrollView {
            id: scrollArea

            ListView {
                id: listview

                width: parent.width
                height: contentHeight

                spacing: Kirigami.Units.smallSpacing
                model: daysSinceModel

                highlight: PlasmaExtras.Highlight {}
                currentIndex: -1

                delegate: DaysSinceItem {}
            }

            PlasmaExtras.PlaceholderMessage {
                id: placeholder

                anchors.centerIn: parent
                anchors.verticalCenterOffset: 2 * Kirigami.Units.gridUnit
                width: parent.width - (Kirigami.Units.largeSpacing * 4)
                height: parent.height

                visible: listview.count == 0
                iconName: "appointment-new"
                text: i18n("No events added")
                explanation: i18n("Add events in widget configuration to see them here.")
            }
        }
    }
}
