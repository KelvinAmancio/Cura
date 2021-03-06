// Copyright (c) 2019 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.0 as Cura


//
// This is the scroll view widget for adding a (local) printer. This scroll view shows a list view with printers
// categorized into 3 categories: "Ultimaker", "Custom", and "Other".
//
ScrollView
{
    id: base

    // The currently selected machine item in the local machine list.
    property var currentItem: (machineList.currentIndex >= 0)
                              ? machineList.model.getItem(machineList.currentIndex)
                              : null
    // The currently active (expanded) section/category, where section/category is the grouping of local machine items.
    property string currentSection: preferredCategory
    // By default (when this list shows up) we always expand the "Ultimaker" section.
    property string preferredCategory: "Ultimaker"

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    property int maxItemCountAtOnce: 10  // show at max 10 items at once, otherwise you need to scroll.
    height: maxItemCountAtOnce * UM.Theme.getSize("action_button").height

    clip: true

    function updateCurrentItemUponSectionChange()
    {
        // Find the first machine from this section
        for (var i = 0; i < machineList.count; i++)
        {
            var item = machineList.model.getItem(i)
            if (item.section == base.currentSection)
            {
                machineList.currentIndex = i
                break
            }
        }
    }

    Component.onCompleted:
    {
        updateCurrentItemUponSectionChange()
    }

    ListView
    {
        id: machineList

        model: UM.DefinitionContainersModel
        {
            id: machineDefinitionsModel
            filter: { "visible": true }
            sectionProperty: "category"
            preferredSectionValue: preferredCategory
        }

        section.property: "section"
        section.delegate: sectionHeader
        delegate: machineButton
    }

    Component
    {
        id: sectionHeader

        Button
        {
            id: button
            width: ListView.view.width
            height: UM.Theme.getSize("action_button").height
            text: section

            property bool isActive: base.currentSection == section

            background: Rectangle
            {
                anchors.fill: parent
                color: isActive ? UM.Theme.getColor("setting_control_highlight") : "transparent"
            }

            contentItem: Item
            {
                width: childrenRect.width
                height: UM.Theme.getSize("action_button").height

                UM.RecolorImage
                {
                    id: arrow
                    anchors.left: parent.left
                    width: UM.Theme.getSize("standard_arrow").width
                    height: UM.Theme.getSize("standard_arrow").height
                    sourceSize.width: width
                    sourceSize.height: height
                    color: UM.Theme.getColor("text")
                    source: base.currentSection == section ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_right")
                }

                Label
                {
                    id: label
                    anchors.left: arrow.right
                    anchors.leftMargin: UM.Theme.getSize("default_margin").width
                    verticalAlignment: Text.AlignVCenter
                    text: button.text
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }

            onClicked:
            {
                base.currentSection = section
                base.updateCurrentItemUponSectionChange()
            }
        }
    }

    Component
    {
        id: machineButton

        Cura.RadioButton
        {
            id: radioButton
            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("standard_list_lineheight").width
            anchors.right: parent.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            height: visible ? UM.Theme.getSize("standard_list_lineheight").height : 0

            checked: ListView.view.currentIndex == index
            onCheckedChanged:
            {
                if(checked)
                {
                    machineList.currentIndex = index
                }
            }
            text: name
            visible: base.currentSection == section
            onClicked: ListView.view.currentIndex = index
        }
    }
}
