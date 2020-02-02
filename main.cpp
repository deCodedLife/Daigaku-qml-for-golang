#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include "sources/appcore.h"
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute( Qt::AA_UseHighDpiPixmaps );
    QCoreApplication::setAttribute( Qt::AA_EnableHighDpiScaling );

    QGuiApplication app(argc, argv);//Qt::Window | | Qt::NoDropShadowWindowHint ::CustomizeWindowHint
    QQmlApplicationEngine engine;
    qputenv("QT_SCALE_FACTOR", QByteArray("3"));

    app.setWindowIcon(QIcon("qrc:/images/logo.ico"));
    qmlRegisterType<AppCore>("AppCore", 1, 0, "AppCore");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection );
    qDebug() << app.sessionKey().toUtf8();
    engine.load(url);
    return app.exec();
}
