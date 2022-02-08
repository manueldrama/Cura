// Copyright (c) 2022 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 2.15

// This component extends the funtionality of QtControls 2.x Spinboxes to
// - be able to contain fractional values
// - hava a "prefix" and a "suffix". A validator is added that recognizes this pre-, suf-fix combo. When adding a custom
//    validator the pre-, suf-fix should be added (e.g. new RegExp("^" + prefix + \regex\ + suffix + "$")

Item
{
    id: base

    height: spinBox.height

    property string prefix: ""
    property string suffix: ""
    property int decimals: 0
    property real stepSize: 1
    property real value: 0
    property real from: 0
    property real to: 99

    property alias wrap: spinBox.wrap

    property bool editable: true

    property var validator: RegExpValidator
    {
        regExp: new RegExp("^" + prefix + "([0-9]+[.|,]?[0-9]*)?" + suffix + "$")
    }

    signal editingFinished()

    SpinBox
    {
        id: spinBox
        anchors.fill: base
        editable: base.editable

        // The stepSize of the SpinBox is intentionally set to be always `1`
        // As SpinBoxes can only contain integer values the `base.stepSize` is concidered the precision/resolution
        // increasing the spinBox.value by one increases the actual/real value of the component by `base.stepSize`
        // as such spinBox.value * base.stepSizes produces the real value of the component
        stepSize: 1
        value: Math.floor(base.value / base.stepSize)
        from: Math.floor(base.from / base.stepSize)
        to: Math.floor(base.to / base.stepSize)

        valueFromText: function(text)
        {
            return parseFloat(text.substring(prefix.length, text.length - suffix.length)) / base.stepSize;
        }

        textFromValue: function(value)
        {
            return prefix + (value * base.stepSize).toFixed(decimals) + suffix;
        }

        validator: base.validator

        onValueModified:
        {
            base.value = value * base.stepSize;
        }

        contentItem: TextField
        {
            text: spinBox.textFromValue(spinBox.value, spinBox.locale)
            selectByMouse: base.editable
            background: Item {}
            validator: base.validator

            onActiveFocusChanged:
            {
                if(!activeFocus)
                {
                    base.editingFinished();
                }
            }
        }
    }
}
