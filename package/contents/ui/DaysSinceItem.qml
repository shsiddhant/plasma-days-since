/*
	SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

	SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PC
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PC.ItemDelegate {
  id: itemDelegate

  required property string title
  required property string date
  required property int days
  required property int index

  width: ListView.view.width
  hoverEnabled: true

  Loader {
	anchors.fill: parent
	active: itemDelegate.hovered || itemDelegate.activeFocus
	asynchronous: true
	z: -1

	sourceComponent: PlasmaExtras.Highlight {
	  hovered: true
	}
  }

  // Disable extra Qt Quick ToolTip
  QQC2.ToolTip.visible: false

  PC.ToolTip.visible: itemDelegate.hovered && titleLabel.truncated

  contentItem: RowLayout {
	PC.ToolTip  {
	  visible: itemDelegate.hovered && titleLabel.truncated
	  text: itemDelegate.title
	  delay: Kirigami.Units.toolTipDelay
	}

	PC.Label {
	  text: itemDelegate.days
	  font.bold: true
	  font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
	  horizontalAlignment: Text.AlignRight
	  Layout.preferredWidth: Kirigami.Units.gridUnit * 2.8
	  Layout.alignment: Qt.AlignVCenter
	}

	PC.Label {
	  text: " • "
	  opacity: 0.35
	  Layout.alignment: Qt.AlignVCenter
	}

	ColumnLayout {
	  spacing: 0
	  Layout.fillWidth: true
	  Layout.alignment: Qt.AlignVCenter

	  PC.Label {
		id: titleLabel
		text: itemDelegate.title
		font.bold: true
		elide: Text.ElideRight
		Layout.fillWidth: true
	  }

	  PC.Label {
		text: itemDelegate.date
		opacity: 0.55
		font.pointSize: Kirigami.Theme.smallFont.pointSize
		Layout.fillWidth: true
	  }
	}
  }
}
