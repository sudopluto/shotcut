/*
 * Copyright (c) 2021 Meltytech, LLC
 * Written by Austin Brooks <ab.shotcut@outlook.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import Shotcut.Controls 1.0 as Shotcut


Shotcut.KeyframableFilter {
    // Constants

    property double thresholdMin: 0.00003
    property double thresholdMax: 0.5
    property double directionMax: 6.28319


    // Parameters

    property string thr1Param: 'av.1thr'
    property double thr1Default: 0.0100294

    property string thr2Param: 'av.2thr'
    property double thr2Default: 0.0100294

    property string thr3Param: 'av.3thr'
    property double thr3Default: 0.0100294

    property string thr4Param: 'av.4thr'
    property double thr4Default: 0.0100294

    property string linkParam: 'ui.link'
    property bool linkDefault: true

    property string rangeParam: 'av.range'
    property int rangeDefault: 23

    property string directionParam: 'av.direction'
    property double directionDefault: directionMax

    property string blurParam: 'av.blur'
    property bool blurDefault: true

    property string couplingParam: 'av.coupling'
    property bool couplingDefault: false

    property var allParams: [thr1Param, thr2Param, thr3Param, thr4Param, linkParam, rangeParam, directionParam, blurParam, couplingParam]

    keyframableParameters: ['av.1thr', 'av.2thr', 'av.3thr', 'av.4thr', 'av.range', 'av.direction']
    startValues: [thr1Default, thr2Default, thr3Default, thr4Default, rangeDefault, directionDefault]
    middleValues: [thr1Default, thr2Default, thr3Default, thr4Default, rangeDefault, directionDefault]
    endValues: [thr1Default, thr2Default, thr3Default, thr4Default, rangeDefault, directionDefault]


    // Conversion functions between filter and UI units

    function pctToThr (value) {
        return (thresholdMax - thresholdMin) * (value / 100) + thresholdMin
    }


    function thrToPct (value) {
        return Math.round(((value - thresholdMin) / (thresholdMax - thresholdMin) + Number.EPSILON) * 1000) / 10
    }


    function sqrToRoot (value) {
        return Math.round((Math.sqrt(Math.abs(value)) + Number.EPSILON) * 10) / 10
    }


    function rootToSqr (value) {
        return Math.round(value * value + Number.EPSILON)
    }


    function radToDeg (value) {
        return Math.round(Math.abs(value / directionMax * 360) + Number.EPSILON)
    }


    function degToRad (value) {
        return value / 360 * directionMax
    }


    // UI management functions

    function setThreshold (param, pct, keyframesButton, position) {
        if (idLink.checked) {
            var thr = pctToThr(pct)

            updateFilter(thr1Param, thr, thr1KeyframesButton, position)
            updateFilter(thr2Param, thr, thr2KeyframesButton, position)
            updateFilter(thr3Param, thr, thr3KeyframesButton, position)
            updateFilter(thr4Param, thr, thr4KeyframesButton, position)

            idThr1.value = pct
            idThr2.value = pct
            idThr3.value = pct
            idThr4.value = pct
        }
        else {
            updateFilter(param, pctToThr(pct), keyframesButton, position)
        }
    }

    function hasKeyframes(param) {
        return filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(param) > 0
    }

    function setControls () {
        idLink.checked = false
        var position = getPosition()
        blockUpdate = true
        idThr1.value = thrToPct(filter.getDouble(thr1Param, position))
        thr1KeyframesButton.checked = hasKeyframes(thr1Param)
        idThr2.value = thrToPct(filter.getDouble(thr2Param, position))
        thr2KeyframesButton.checked = hasKeyframes(thr2Param)
        idThr3.value = thrToPct(filter.getDouble(thr3Param, position))
        thr3KeyframesButton.checked = hasKeyframes(thr3Param)
        idThr4.value = thrToPct(filter.getDouble(thr4Param, position))
        thr4KeyframesButton.checked = hasKeyframes(thr4Param)
        idLink.checked = parseInt(filter.get(linkParam))

        // The Randomize checkboxes must be set first or else sign inversion will happen.
        idRangeRand.checked = parseInt(filter.get(rangeParam)) >= 0 ? true : false
        idRange.value = sqrToRoot(parseInt(filter.getDouble(rangeParam, position)))
        rangeKeyframesButton.checked = hasKeyframes(rangeParam)
        idDirectionRand.checked = filter.getDouble(directionParam) >= 0 ? true : false
        idDirection.value = radToDeg(filter.getDouble(directionParam, position))
        directionKeyframesButton.checked = hasKeyframes(directionParam)
        blockUpdate = false

        idBlur.checked = parseInt(filter.get(blurParam))
        idCoupling.checked = parseInt(filter.get(couplingParam))
        enableControls(isSimpleKeyframesActive())
    }

    function enableControls(enabled) {
        idThr1.enabled = enabled
        idThr2.enabled = enabled
        idThr3.enabled = enabled
        idThr4.enabled = enabled
        idRange.enabled = enabled
        idDirection.enabled = enabled
    }

    function updateSimpleKeyframes() {
        setThreshold(thr1Param, idThr1.value, thr1KeyframesButton, null)
        setThreshold(thr2Param, idThr2.value, thr2KeyframesButton, null)
        setThreshold(thr3Param, idThr3.value, thr3KeyframesButton, null)
        setThreshold(thr4Param, idThr4.value, thr4KeyframesButton, null)
        updateFilter(rangeParam, idRange.storedValue, rangeKeyframesButton, null)
        updateFilter(directionParam, idDirection.storedValue, directionKeyframesButton, null)
    }

    Component.onCompleted: {
        filter.blockSignals = true
        if (filter.isNew) {
            // Custom preset
            filter.set(thr1Param, 0.0100294)
            filter.set(thr2Param, 0.0100294)
            filter.set(thr3Param, 0.0100294)
            filter.set(thr4Param, 0.0100294)
            filter.set(linkParam, true)
            filter.set(rangeParam, 23)
            filter.set(directionParam, directionMax)
            filter.set(blurParam, true)
            filter.set(couplingParam, false)
            filter.savePreset(allParams, qsTr('Minimal strength'))

            // Custom preset
            filter.set(thr1Param, 0.02)
            filter.set(thr2Param, 0.02)
            filter.set(thr3Param, 0.02)
            filter.set(thr4Param, 0.02)
            filter.set(linkParam, true)
            filter.set(rangeParam, 16)
            filter.set(directionParam, directionMax)
            filter.set(blurParam, true)
            filter.set(couplingParam, false)
            filter.savePreset(allParams, qsTr('Average strength'))

            // Custom preset
            filter.set(thr1Param, 0.0150291)
            filter.set(thr2Param, 0.03994)
            filter.set(thr3Param, 0.0150291)
            filter.set(thr4Param, 0.0150291)
            filter.set(linkParam, false)
            filter.set(rangeParam, 90)
            filter.set(directionParam, directionMax)
            filter.set(blurParam, true)
            filter.set(couplingParam, false)
            filter.savePreset(allParams, qsTr('Blue sky'))

            // Custom preset
            filter.set(thr1Param, 0.0150291)
            filter.set(thr2Param, 0.0150291)
            filter.set(thr3Param, 0.03994)
            filter.set(thr4Param, 0.0150291)
            filter.set(linkParam, false)
            filter.set(rangeParam, 44)
            filter.set(directionParam, directionMax)
            filter.set(blurParam, true)
            filter.set(couplingParam, false)
            filter.savePreset(allParams, qsTr('Red sky'))

            // Custom preset
            filter.set(thr1Param, thr1Default)
            filter.set(thr2Param, thr2Default)
            filter.set(thr3Param, thr3Default)
            filter.set(thr4Param, thr4Default)
            filter.set(linkParam, linkDefault)
            filter.set(rangeParam, rangeDefault)
            filter.set(directionParam, directionDefault)
            filter.set(blurParam, blurDefault)
            filter.set(couplingParam, couplingDefault)
            filter.savePreset(allParams, qsTr('Full range to limited range'))

            // Default preset
            // Same as "Full to limited" preset; assumed most common use case
            filter.savePreset(allParams)
        }
        filter.blockSignals = false

        setControls()
    }


    width: 500
    height: 360


    GridLayout {
        columns: 4
        anchors.fill: parent
        anchors.margins: 8

        // Row split

        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.Preset {
            id: idPreset
            Layout.columnSpan: 3
            parameters: allParams
            onBeforePresetLoaded: resetSimpleKeyframes()
            onPresetSelected: {
                setControls()
                initializeSimpleKeyframes()
            }
        }

        // Row split

        Label {
            text: qsTr('Contrast threshold')
            Shotcut.HoverTip { text: qsTr('Banding similarity within first component\nY (luma) in YCbCr mode\nRed in RGB mode') }
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.SliderSpinner {
            id: idThr1
            minimumValue: 0
            maximumValue: 100
            decimals: 1
            suffix: ' %'
            onValueChanged: setThreshold(thr1Param, value, thr1KeyframesButton, getPosition())
        }
        Shotcut.UndoButton {
            onClicked: idThr1.value = thrToPct(thr1Default)
        }
        Shotcut.KeyframesButton {
            id: thr1KeyframesButton
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, thr1Param, pctToThr(idThr1.value))
            }
        }

        // Row split

        Label {
            text: qsTr('Blue threshold')
            Shotcut.HoverTip { text: qsTr('Banding similarity within second component\nCb (blue) in YCbCr mode\nGreen in RGB mode') }
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.SliderSpinner {
            id: idThr2
            minimumValue: 0
            maximumValue: 100
            decimals: 1
            suffix: ' %'
            onValueChanged: setThreshold(thr2Param, value, thr2KeyframesButton, getPosition())
        }
        Shotcut.UndoButton {
            onClicked: idThr2.value = thrToPct(thr2Default)
        }
        Shotcut.KeyframesButton {
            id: thr2KeyframesButton
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, thr2Param, pctToThr(idThr2.value))
            }
        }

        // Row split

        Label {
            text: qsTr('Red threshold')
            Shotcut.HoverTip { text: qsTr('Banding similarity within third component\nCr (red) in YCbCr mode\nBlue in RGB mode') }
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.SliderSpinner {
            id: idThr3
            minimumValue: 0
            maximumValue: 100
            decimals: 1
            suffix: ' %'
            onValueChanged: setThreshold(thr3Param, value, thr3KeyframesButton, getPosition())
        }
        Shotcut.UndoButton {
            onClicked: idThr3.value = thrToPct(thr3Default)
        }
        Shotcut.KeyframesButton {
            id: thr3KeyframesButton
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, thr3Param, pctToThr(idThr3.value))
            }
        }

        // Row split

        Label {
            text: qsTr('Alpha threshold')
            Shotcut.HoverTip { text: qsTr('Banding similarity within fourth component') }
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.SliderSpinner {
            id: idThr4
            minimumValue: 0
            maximumValue: 100
            decimals: 1
            suffix: ' %'
            onValueChanged: setThreshold(thr4Param, value, thr4KeyframesButton, getPosition())
        }
        Shotcut.UndoButton {
            onClicked: idThr4.value = thrToPct(thr4Default)
        }
        Shotcut.KeyframesButton {
            id: thr4KeyframesButton
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, thr4Param, pctToThr(idThr4.value))
            }
        }

        // Row split

        Item {
            Layout.fillWidth: true
        }
        CheckBox {
            id: idLink
            text: qsTr('Link thresholds')
            onClicked: filter.set(linkParam, checked)
        }
        Item {
            Layout.fillWidth: true
            Layout.columnSpan: 2
        }

        // Row split

        Label {
            text: qsTr('Pixel range')
            Shotcut.HoverTip { text: qsTr('The size of bands being targeted') }
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.SliderSpinner {
            id: idRange
            minimumValue: 0
            maximumValue: 64
            decimals: 1
            property int storedValue: idRangeRand.checked ? rootToSqr(value) : -rootToSqr(value)
            onValueChanged: updateFilter(rangeParam, storedValue, rangeKeyframesButton, getPosition())

        }
        Shotcut.UndoButton {
            onClicked: {
                filter.set(rangeParam, rangeDefault)
                setControls()
            }
        }
        Shotcut.KeyframesButton {
            id: rangeKeyframesButton
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, rangeParam, idRange.storedValue)
            }
        }

        // Row split

        Item {
            Layout.fillWidth: true
        }
        CheckBox {
            id: idRangeRand
            text: qsTr('Randomize pixel range between zero and value')
            onClicked: filter.set(rangeParam, checked ? rootToSqr(idRange.value) : -rootToSqr(idRange.value))
        }
        Item {
            Layout.fillWidth: true
            Layout.columnSpan: 2
        }

        // Row split

        Label {
            text: qsTr('Direction')
            Shotcut.HoverTip { text: qsTr('Up = 270°\nDown = 90°\nLeft = 180°\nRight = 0° or 360°\nAll = 360° + Randomize') }
            Layout.alignment: Qt.AlignRight
        }
        Shotcut.SliderSpinner {
            id: idDirection
            minimumValue: 0
            maximumValue: 360
            suffix: ' °'
            property real storedValue: idDirectionRand.checked ? degToRad(value) : -degToRad(value)
            onValueChanged: updateFilter(directionParam, storedValue, directionKeyframesButton, getPosition())
        }
        Shotcut.UndoButton {
            onClicked: {
                filter.set(directionParam, directionDefault)
                setControls()
            }
        }
        Shotcut.KeyframesButton {
            id: directionKeyframesButton
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, directionParam, idDirection.storedValue)
            }
        }

        // Row split

        Item {
            Layout.fillWidth: true
        }
        CheckBox {
            id: idDirectionRand
            text: qsTr('Randomize direction between zero degrees and value')
            onClicked: filter.set(directionParam, checked ? degToRad(idDirection.value) : -degToRad(idDirection.value))
        }
        Item {
            Layout.fillWidth: true
            Layout.columnSpan: 2
        }

        // Row split

        Item {
            Layout.fillWidth: true
        }
        CheckBox {
            id: idBlur
            text: qsTr('Measure similarity using average of neighbors')
            Shotcut.HoverTip { text: qsTr('Compare to thresholds using average versus exact neighbor values') }
            onClicked: filter.set(blurParam, checked)
        }
        Shotcut.UndoButton {
            onClicked: {
                filter.set(blurParam, blurDefault)
                idBlur.checked = blurDefault
            }
        }
        Item {
            Layout.fillWidth: true
        }

        // Row split

        Item {
            Layout.fillWidth: true
        }
        CheckBox {
            id: idCoupling
            text: qsTr('All components required to trigger deband')
            Shotcut.HoverTip { text: qsTr('Deband only if all pixel components (including alpha) are within thresholds') }
            onClicked: filter.set(couplingParam, checked)
        }
        Shotcut.UndoButton {
            onClicked: {
                filter.set(couplingParam, couplingDefault)
                idCoupling.checked = couplingDefault
            }
        }
        Item {
            Layout.fillWidth: true
        }

        // Filler

        Item {
            Layout.fillHeight: true
        }
    }

    Connections {
        target: filter
        onInChanged: updateSimpleKeyframes()
        onOutChanged: updateSimpleKeyframes()
        onAnimateInChanged: updateSimpleKeyframes()
        onAnimateOutChanged: updateSimpleKeyframes()
        onPropertyChanged: setControls()
    }

    Connections {
        target: producer
        onPositionChanged: setControls()
    }
}
