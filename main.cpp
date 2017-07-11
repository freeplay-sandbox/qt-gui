#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>

#include <ros/ros.h>

#include "fileio.hpp"

int main(int argc, char *argv[])
{
    ros::init(argc, argv,"sandtray");

    FileIO fileio;
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileio", &fileio);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
