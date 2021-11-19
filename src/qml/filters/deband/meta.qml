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
import org.shotcut.qml 1.0

Metadata {
    type: Metadata.Filter
    name: qsTr('Deband')
    objectName: 'deband'
    mlt_service: 'avfilter.deband'
    qml: 'ui.qml'
    keyframes {
        allowAnimateIn: true
        allowAnimateOut: true
        simpleProperties: ['av.1thr', 'av.2thr', 'av.3thr', 'av.4thr', 'av.range', 'av.direction']
        parameters: [
            Parameter {
                name: qsTr('Contrast threshold')
                property: 'av.1thr'
                isSimple: true
                isCurve: true
                minimum: 0.00003
                maximum: 0.5
            },
            Parameter {
                name: qsTr('Blue threshold')
                property: 'av.2thr'
                isSimple: true
                isCurve: true
                minimum: 0.00003
                maximum: 0.5
            },
            Parameter {
                name: qsTr('Red threshold')
                property: 'av.3thr'
                isSimple: true
                isCurve: true
                minimum: 0.00003
                maximum: 0.5
            },
            Parameter {
                name: qsTr('Alpha threshold')
                property: 'av.4thr'
                isSimple: true
                isCurve: true
                minimum: 0.00003
                maximum: 0.5
            },
            Parameter {
                name: qsTr('Pixel range')
                property: 'av.range'
                isSimple: true
                isCurve: true
                minimum: 0
                maximum: 64
            },
            Parameter {
                name: qsTr('Direction')
                property: 'av.direction'
                isSimple: true
                isCurve: true
                minimum: 0
                maximum: 360
            }
        ]
    }
}
