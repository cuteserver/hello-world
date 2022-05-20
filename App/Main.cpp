//
// Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
// All rights reserved
//

#if !defined(WASM)
#include "../SharedLibrary/HelloText.h"
#endif

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#if defined(ANDROID)
#if QT_VERSION < QT_VERSION_CHECK(6,0,0)
#include <QtAndroidExtras/QtAndroid>
#else
#include <QJniObject>
#endif
#endif


#if defined(ANDROID)
int __attribute__ ((visibility ("default"))) main(int argc, char ** argv)
#else
int main(int argc, char ** argv)
#endif
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/app.qml")));
#if !defined(WASM)
    auto rootObjects = engine.rootObjects();
    for (auto &rootObject : rootObjects)
    {
        auto textObject = rootObject->findChild<QObject*>("appTextItem");
        if (textObject)
            textObject->setProperty("text", HelloText::getText());
    }
#endif
    if (engine.rootObjects().isEmpty()) return -1;
#if defined(ANDROID)
#if QT_VERSION < QT_VERSION_CHECK(6,0,0)
    QtAndroid::hideSplashScreen(250);
#else
    QNativeInterface::QAndroidApplication::hideSplashScreen(250);
#endif
#endif
    return QGuiApplication::exec();
}
