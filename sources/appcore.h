#ifndef APPCORE_H
#define APPCORE_H

#include <QtSql>
#include <QPair>
#include <QObject>
#include <QString>
#include <QEventLoop>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QHttpMultiPart>
#include <QNetworkReply>

class AppCore : public QObject
{
    Q_OBJECT
public:
    explicit AppCore (QObject *parent = 0);
    Q_INVOKABLE QJsonObject loadUserData ();
    Q_INVOKABLE QJsonObject getConfig ();
    Q_INVOKABLE QJsonArray getMessages ();
    Q_INVOKABLE QJsonArray getTags ();
    Q_INVOKABLE QJsonArray getImages ( QString tag );
    Q_INVOKABLE QJsonArray getTasksDb ();

    Q_INVOKABLE QJsonObject igetGroups( QString curator = "0" );
    Q_INVOKABLE QJsonObject igetTags( int all = 0, QString group = "" );
    Q_INVOKABLE QJsonObject igetImages( QString tag, QString date = "" );
    Q_INVOKABLE QJsonObject userImage ( QString url );
    Q_INVOKABLE QJsonObject getUsers ( int s, QString group = "" );
    Q_INVOKABLE QJsonObject getUser ( QString username );
    Q_INVOKABLE QJsonObject getDocs ( int id = 0, int self = 0 );

    Q_INVOKABLE QJsonObject getTest( int self = 0, QString group = "0" );
    Q_INVOKABLE QJsonObject getHome( int self = 0, QString group = "0" );
    Q_INVOKABLE QJsonObject getTaskData( int all = 0, int id = 0 );
    Q_INVOKABLE QJsonObject getHomeData( int all = 0, int id = 0 );
    Q_INVOKABLE QString deleteTask( int id );
    Q_INVOKABLE QString deleteHome( int id );
    Q_INVOKABLE QString applyTest( int id, QString mark = "0", QString user = "", int type = 0 );
    Q_INVOKABLE QString applyHome( int id, QString mark = "0", QString user = "", int type = 0 );
    Q_INVOKABLE QString updateTest( int id, QString task, QString docs, QString description );
    Q_INVOKABLE QString updateHome( int id, QString task, QString docs, QString description );
    Q_INVOKABLE QString addTest( QString group, QString tag, QString task, QString docs, QString groups, QString description );
    Q_INVOKABLE QString addHome( QString group, QString tag, QString task, QString docs, QString groups, QString description );

    Q_INVOKABLE QJsonObject getCurator();
    Q_INVOKABLE QJsonObject getProfile( QString username = "" );
    Q_INVOKABLE QJsonObject getTasks( QString self, QString group = "" );
    Q_INVOKABLE QJsonObject getMyProfile();

    Q_INVOKABLE void update ( QString username, QString password );
    Q_INVOKABLE QJsonObject profileImage( QString url );

    Q_INVOKABLE QString post ( QString url, QJsonObject json );
    Q_INVOKABLE QString getToken ( QString username, QString password );
    Q_INVOKABLE QString getCuratorTag( QString tag );
    Q_INVOKABLE QString sendImage ( QString files, QString data, QStringList args = *new(QStringList) );
    Q_INVOKABLE QString sendMessage ( QString pick, QString message );
    Q_INVOKABLE QString sendTag (QString tagName, QString curator = "", QString group = "" );
    Q_INVOKABLE QString sendTask ( QString group, QString tagName, QString task, QString date_to );
    Q_INVOKABLE QString selectTask ( QString id );
    Q_INVOKABLE QString applyTask ( QString id );
    Q_INVOKABLE QString changeGroup( QString username, QString group );
    Q_INVOKABLE QString newuser( QString username, QString password, QString group );
    Q_INVOKABLE QString newUser( QString username, QString group, QString status );
    Q_INVOKABLE QString selectStudent( QString id, QString user );
    Q_INVOKABLE QString changeDocPerm( int id, int perm = 0 );

    Q_INVOKABLE QString deleteImage ( QString path );
    Q_INVOKABLE QString deleteMessage ( QString pick, QString message, QString date );
    Q_INVOKABLE QString deleteTag ( QString group, QString tag, QString curator );
    Q_INVOKABLE QString deleteTask( QString id );
    Q_INVOKABLE QString deleteUser( QString username );
    Q_INVOKABLE QString getHashed( QString string );
    Q_INVOKABLE QString deleteDoc( int id );
    Q_INVOKABLE void uMessages ();
    Q_INVOKABLE void uTags ();
    Q_INVOKABLE void uImages ();
    Q_INVOKABLE void uTasks ();
    Q_INVOKABLE void close();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void updateUser();
    Q_INVOKABLE void saveFile( QString path, QString url );

    Q_INVOKABLE int checkConnection ();
    Q_INVOKABLE QString token;
    typedef QPair<QByteArray, QByteArray> RawHeaderPair;
private:
    QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE");
    QNetworkAccessManager *netManager = new QNetworkAccessManager();
    QNetworkRequest netRequest;
    QNetworkReply *netReply;
    QEventLoop loop;
    QString api = "http://95.142.40.58:8080";

    int checkable = 0;
    QByteArray userIco;
    QJsonObject *jsonObj;
};

#endif // APPCORE_H
