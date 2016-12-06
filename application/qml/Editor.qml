/****************************************************************************
**
** Copyright (C) 2014-2016 Dinu SV.
** (contact: mail@dinusv.com)
** This file is part of Live CV Application.
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
****************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import Cv 1.0

Rectangle{
    id : editor

    signal save()
    signal open()
    signal toggleSize()

    property bool isDirty: false
    property alias text: editorArea.text
    property alias font: editorArea.font

    color : "#071723"
    gradient: Gradient{
        GradientStop { position: 0.0;  color: "#08141f" }
        GradientStop { position: 0.01; color: "#071723" }
    }

    clip : true

    function forceFocus(){
        editorArea.forceActiveFocus()
    }

    ScrollView {
        id: flick
        style: ScrollViewStyle {
            transientScrollBars: false
            handle: Item {
                implicitWidth: 10
                implicitHeight: 10
                Rectangle {
                    color: "#0b1f2e"
                    anchors.fill: parent
                }
            }
            scrollBarBackground: Item{
                implicitWidth: 10
                implicitHeight: 10
                Rectangle{
                    anchors.fill: parent
                    color: "#091a27"
                }
            }
            decrementControl: null
            incrementControl: null
            frame: Rectangle{color: "#071723"}
            corner: Rectangle{color: "#071723"}
        }

        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.topMargin: 8

        frameVisible: false

        function ensureVisible(r){
            if (flickableItem.contentX >= r.x)
                flickableItem.contentX = r.x;
            else if (flickableItem.contentX + width <= r.x + r.width + 20)
                flickableItem.contentX = r.x + r.width - width + 20;
            if (flickableItem.contentY >= r.y)
                flickableItem.contentY = r.y;
            else if (flickableItem.contentY + height <= r.y + r.height + 20)
                flickableItem.contentY = r.y + r.height - height + 20;
        }

        TextEdit {
            id : editorArea

            property int lastLength: 0

            onCursorRectangleChanged: {
                flick.ensureVisible(cursorRectangle)
            }
            onCursorPositionChanged: {
                // disable the model if no text has changed, let the code handler decide otherwise
                if ( length === lastLength )
                    codeHandler.completionModel.disable()
                lastLength = length
            }

            focus : true
            text : project.inFocus ? project.inFocus.content : ''

            color : "#fff"
            font.family: "Source Code Pro, Ubuntu Mono, Courier New, Courier"
            font.pixelSize: 13
            font.weight: Font.Light

            selectByMouse: true
            mouseSelectionMode: TextEdit.SelectCharacters
            selectionColor: "#3d4856"

            textFormat: TextEdit.PlainText

            wrapMode: TextEdit.NoWrap
            height : Math.max( flick.height - 20, paintedHeight )
            width : Math.max( flick.width - 20, paintedWidth )

            Keys.onPressed: {
                if ( (event.key === Qt.Key_BracketRight && (event.modifiers & Qt.ShiftModifier) ) ||
                     (event.key === Qt.Key_BraceRight) ){

                    event.accepted = true
                    if ( cursorPosition > 4 ){
                        var clastpos = cursorPosition
                        if( editorArea.text.substring(cursorPosition - 4, cursorPosition) === "    " ){
                            editorArea.text = editorArea.text.slice(0, clastpos - 4) + "}" + editorArea.text.slice(clastpos)
                            cursorPosition = clastpos - 3
                        } else {
                            editorArea.text = editorArea.text.slice(0, clastpos) + "}" + editorArea.text.slice(clastpos)
                            cursorPosition = clastpos + 1
                        }
                    }
                } else if ( event.key === Qt.Key_Space && (event.modifiers & Qt.ControlModifier ) ){
                    codeHandler.generateCompletion(cursorPosition)
                    event.accepted = true
                } else if ( event.key === Qt.Key_Escape ){
                    codeHandler.completionModel.disable()
                } else if ( event.key === Qt.Key_S && (event.modifiers & Qt.ControlModifier ) ){
                    editor.save()
                    event.accepted = true
                } else if ( event.key === Qt.Key_O && (event.modifiers & Qt.ControlModifier ) ) {
                    editor.open()
                    event.accepted = true
                } else if ( event.key === Qt.Key_E && (event.modifiers & Qt.ControlModifier ) ){
                    editor.toggleSize()
                    event.accepted = true
                } else if ( event.key === Qt.Key_PageUp ){
                    var lines = flick.height / cursorRectangle.height
                    var prevLineStartPos = editorArea.text.lastIndexOf('\n', cursorPosition - 1)
                    while ( --lines > 0 ){
                        cursorPosition   = prevLineStartPos + 1
                        prevLineStartPos = editorArea.text.lastIndexOf('\n', cursorPosition - 2)
                        if ( prevLineStartPos === -1 ){
                            cursorPosition = 0;
                            break;
                        }
                    }
                    event.accepted = true
                } else if ( event.key === Qt.Key_PageDown ){
                    var lines = flick.height / cursorRectangle.height
                    var nextLineStartPos = editorArea.text.indexOf('\n', cursorPosition)
                    while ( lines-- > 0 && nextLineStartPos !== -1 ){
                        cursorPosition   = nextLineStartPos + 1
                        nextLineStartPos = editorArea.text.indexOf('\n', cursorPosition)
                    }
                    event.accepted = true
                } else if ( event.key === Qt.Key_Down ){
                    if ( codeHandler.completionModel.isEnabled ){
                        event.accepted = true
                        qmlSuggestionBox.incrementSelection()
                    }
                } else if ( event.key === Qt.Key_Up ){
                    if ( codeHandler.completionModel.isEnabled ){
                        event.accepted = true
                        qmlSuggestionBox.decrementSelection()
                    }
                } else
                    event.accepted = false
            }

            Keys.onReturnPressed: {
                event.accepted = false
                if ( codeHandler.completionModel.isEnabled ){
                    codeHandler.insertCompletion(
                        codeHandler.completionModel.completionPosition,
                        cursorPosition,
                        qmlSuggestionBox.getCompletion()
                    )
                    event.accepted = true
                }

//                event.accepted = true
//                var clastpos = cursorPosition
//                var append = ""
//                var cpos = cursorPosition - 1
//                var bracketSearchEnd = false
//                while ( cpos > 0 ){
//                    if ( !bracketSearchEnd ){
//                        if ( editorArea.text.charAt(cpos) !== ' ' ){
//                            if ( editorArea.text.charAt(cpos) === '{' ){
//                                append += "    "
//                                bracketSearchEnd = true
//                            } else {
//                                bracketSearchEnd = true
//                            }
//                        }
//                    }// bracket search
//                    if ( editorArea.text.charAt(cpos) === '\n' ){
//                        ++cpos;
//                        while( editorArea.text.charAt(cpos) === '\t' || editorArea.text.charAt(cpos) === ' ' ){
//                            append += editorArea.text.charAt(cpos)
//                            ++cpos
//                        }
//                        break;
//                    }
//                    --cpos;
//                }
//                editorArea.text = editorArea.text.slice(0, clastpos) + "\n" + append + editorArea.text.slice(clastpos)
//                editorArea.cursorPosition = clastpos + 1 + append.length
            }
            Keys.onTabPressed: {
                event.accepted = true
                var clastpos = cursorPosition
                editorArea.text = editorArea.text.slice(0, clastpos) + "    " + editorArea.text.slice(clastpos)
                editorArea.cursorPosition = clastpos + 4
            }

            Component.onCompleted: {
                editor.isDirty = false
                codeHandler.target = textDocument
            }

            Behavior on font.pixelSize {
                NumberAnimation { duration: 40 }
            }

            Connections{
                target: codeHandler
                onCursorPositionRequest : editorArea.cursorPosition = position
            }

            MouseArea{
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.IBeamCursor
            }

        }

    }

    SuggestionBox{
        id: qmlSuggestionBox

        fontFamily: editorArea.font.family
        fontSize: editorArea.font.pixelSize
        visible: codeHandler.completionModel.isEnabled && suggestionCount > 0
        opacity: visible ? 0.95 : 0

        y: {
            var calculatedY =
                editorArea.cursorRectangle.y +
                editorArea.cursorRectangle.height + 10 -
                flick.flickableItem.contentY

            if ( calculatedY > flick.height - height )
                calculatedY = editorArea.cursorRectangle.y - height - flick.flickableItem.contentY
            return calculatedY;
        }
        x: {
            var calculatedX =
                editorArea.positionToRectangle(codeHandler.completionModel.completionPosition).x -
                flick.flickableItem.contentX

            if ( calculatedX > flick.width - width)
                calculatedX = flick.width - width
            return calculatedX;
        }
        model: codeHandler.completionModel

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

}

