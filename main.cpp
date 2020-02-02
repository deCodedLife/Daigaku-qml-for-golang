#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include "sources/appcore.h"
#include "sources/app.h"
#include "sources/ufile.h"
#include <QDebug>
//#include <QQuickView>

int main(int argc, char *argv[])
{
    App core();
    QGuiApplication::setAttribute( Qt::AA_UseHighDpiPixmaps );
    QCoreApplication::setAttribute( Qt::AA_EnableHighDpiScaling );

    QGuiApplication app(argc, argv);//Qt::Window | | Qt::NoDropShadowWindowHint ::CustomizeWindowHint
    QQmlApplicationEngine engine;
    qputenv("QT_SCALE_FACTOR", QByteArray("3"));

    //QQuickView* view = new QQuickView;
    //view->setFlags( Qt::Window | Qt::NoDropShadowWindowHint | Qt::CustomizeWindowHint );

    app.setWindowIcon(QIcon("qrc:/images/logo.ico"));
    qmlRegisterType<UFile>("UFile", 0,1, "UFile");
    qmlRegisterType<AppCore>("AppCore", 1, 0, "AppCore");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection );
    qDebug() << app.sessionKey().toUtf8();
    //app.platformNativeInterface();
    engine.load(url);
    return app.exec();
}
