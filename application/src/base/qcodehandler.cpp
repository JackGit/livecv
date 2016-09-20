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
#include "qcodehandler.h"
#include "qcodejshighlighter_p.h"

#include <QQuickTextDocument>

QCodeHandler::QCodeHandler(QQuickItem *parent)
    : QQuickItem(parent)
    , m_target(0)
    , m_highlighter(0){

}

QCodeHandler::~QCodeHandler(){
    // m_target and m_highlighter are not owned by this document
}

void QCodeHandler::setTarget(QQuickTextDocument *target){

    m_target      = target;
    m_highlighter = new QCodeJSHighlighter(m_target->textDocument());

    emit targetChanged();
}
