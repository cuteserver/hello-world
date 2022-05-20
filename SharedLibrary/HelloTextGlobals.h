//
// Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
// All rights reserved
//

#ifndef HELLO_TEXT_GLOBALS_H
#define HELLO_TEXT_GLOBALS_H

#include <QtCore/QtGlobal>

#if defined(HELLOWORLD_LIBRARY)
#  define HELLOWORLD_EXPORT Q_DECL_EXPORT
#else
#  define HELLOWORLD_EXPORT Q_DECL_IMPORT
#endif

#endif // HELLO_TEXT_GLOBALS_H
