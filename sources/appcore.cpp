#include "appcore.h"

#include <iostream>
using namespace std;

AppCore::AppCore( QObject *parent ) : QObject (parent) {    // loading
    int connection = checkConnection();
    if ( !QDir("data").exists() ) QDir().mkdir("data");
    database.setDatabaseName("data/database.bin");
    if ( !database.open() ) { qDebug() << database.lastError().text();  return; }
    else {
        if ( !database.tables().contains( QLatin1String("user_data") ) ) {    // if data base not correct
            QSqlQuery query;
            query.exec("CREATE TABLE user_data ( username  TEXT NOT NULL, password TEXT NOT NULL, status TEXT NOT NULL, fgroup TEXT NOT NULL, is_curator INTEGER NOT NULL, profile TEXT NOT NULL);"); // creating user_data table
            query.exec("CREATE TABLE images ( id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, groups TEXT NOT NULL, tag TEXT NOT NULL, date TEXT NOT NULL, path TEXT NOT NULL);");  // creating images table
            query.exec("CREATE TABLE messages ( id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, groups TEXT NOT NULL, pick INTEGER NOT NULL, message TEXT NOT NULL, operator TEXT NOT NULL, date TEXT NOT NULL);");  // creating messages table
            query.exec("CREATE TABLE tags ( id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, groups TEXT NOT NULL, tag TEXT NOT NULL, static INTEGER NOT NULL);");   // cteating tags table
            query.exec("CREATE TABLE config ( first INTEGER NOT NULL, theme INTEGER NOT NULL, trafic INTEGET NOT NULL);");   // creating config table
            query.exec("CREATE TABLE Tasks ( id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, groups TEXT NOT NULL, tag TEXT NOT NULL, task TEXT NOT NULL, attached TEXT NOT NULL, date_to TEXT NOT NULL, operator TEXT NOT NULL, finished INTEGER NOT NULL);");
            query.exec("INSERT INTO user_data (`username`,`password`,`status`,`fgroup`,`is_curator`,`profile`) VALUES (\"\",\"\",\"\",\"\",1,\"\")");  // creating start values
            query.exec("INSERT INTO config (`first`, `theme`, `trafic`) VALUES (1,0,0)");   // set default values
            query.clear();
        }
    }
    QJsonObject userdata = loadUserData();
    if ( connection == 0 && userdata["username"].toString() != "" )
        token = getToken(userdata["username"].toString(), userdata["password"].toString() );
}

QString AppCore::post (QString url, QJsonObject json) {    // GET func
    qDebug() << api + url;
    QJsonDocument jsonDoc (json);
    QByteArray jsonData = jsonDoc.toJson();
    netRequest.setHeader(QNetworkRequest::ContentTypeHeader,"application/json");
    netRequest.setHeader(QNetworkRequest::ContentLengthHeader,QByteArray::number(jsonData.size()));
    if ( checkable == 1 )  netRequest.setUrl( QUrl( url ) );// set url
    else netRequest.setUrl( QUrl( api + url ) );// set url
    netReply = netManager->post( netRequest, jsonData );    // download page with GET method
    netManager->connect( netManager, SIGNAL( finished( QNetworkReply* ) ), &loop, SLOT(quit())); // When page downloaded, programm will exit from loop
    loop.exec();    // starting download page
    if ( checkable == 1 ) userIco = netReply->readAll();
    QString result = netReply->readAll(); // getting text from page
    QList<RawHeaderPair> pairs = netReply->rawHeaderPairs();
    if ( pairs[1].second == "application/text" ) {
        QStringList array = result.split("\"");
        result = array[1];
    }
    return result;  // returning text from page
}
void AppCore::update ( QString username, QString password ) {
    token = getToken( username, password );
    if ( token.length() > 50 ) {
        QString url;
        if ( !database.open() ) qDebug() << "upload func: [ERROR] > " + database.lastError().text();
        else {
            QSqlQuery query;
            QJsonObject user_data = getProfile("");
            query.exec("UPDATE user_data SET `username` = \""+username+"\", `password` = \""+password+"\", `status` = \""+user_data["status"].toString()+"\", `fgroup` = \""+user_data["group"].toString()+"\",`is_curator` = \""+QString::number(user_data["is_curator"].toInt())+"\" , `profile` = \""+user_data["profile"].toString()+"\" "); // updating user data table

            QJsonObject groups = igetGroups();
            query.exec("DELETE FROM tags");     //clear tags
            query.exec("DELETE FROM images");   //clear images
            query.exec("DELETE FROM messages"); //clear messages
            query.exec("DELETE FROM Tasks");    //clear tasks


            QJsonObject tags = igetTags(0, user_data["group"].toString());

            for ( int i = 0; i < tags["tags"].toArray().size(); i++ ) {
                QJsonObject item = tags["tags"].toArray().at(i).toObject();
                QJsonObject images = igetImages(item["tag"].toString(), "");

                for ( int i = 0; i < images["images"].toArray().count(); i++ ) {
                    QJsonObject image = images["images"].toArray().at(i).toObject();
                    query.exec("INSERT INTO images (`groups`,`tag`,`date`,`path`) VALUES (\""+user_data["group"].toString()+"\",\""+item["tag"].toString()+"\",\""+image["date"].toString()+"\",\""+image["image"].toString()+"\")"); // update images
                }

                query.exec("INSERT INTO tags (`groups`, `tag`, `static`) VALUES (\""+user_data["group"].toString()+"\",\""+item["tag"].toString()+"\","+QString::number(item["static"].toInt())+")");  // update tags
            }

            jsonObj = new( QJsonObject );
            jsonObj->insert("token", token);
            QJsonObject messages = QJsonDocument::fromJson( post( "/get-messages", *jsonObj ).toUtf8() ).object();
            delete(jsonObj);

            for ( int i = 0; i < messages["messages"].toArray().count(); i++ ) {
                QJsonObject message = messages["messages"].toArray().at(i).toObject();
                query.exec("INSERT INTO messages (`groups`,`pick`,`message`,`operator`,`date`) VALUES (\""+user_data["group"].toString()+"\","+QString::number(message["pick"].toInt())+",\""+message["message"].toString()+"\",\""+message["operator"].toString()+"\",\""+message["date"].toString()+"\")"); // update messages
            }

            QJsonObject tasks = getTasks("0", "");
            qDebug() << tasks;
            for ( int i = 0; i < tasks["tasks"].toArray().count(); i++ ) {
                QJsonObject task = tasks["tasks"].toArray().at(i).toObject();
                query.prepare("INSERT INTO Tasks (`id`,`groups`,`tag`,`task`,`attached`,`date_to`,`operator`,`finished`) VALUES (?,?,?,?,?,?,?,?)");
                query.addBindValue(task["id"].toInt());
                query.addBindValue(task["group"].toString());
                query.addBindValue(task["tag"].toString());
                query.addBindValue(task["task"].toString());
                query.addBindValue(task["attached"].toString());
                query.addBindValue(task["date_to"].toString());
                query.addBindValue(task["operator"].toString());
                query.addBindValue(task["finished"].toInt());
                if (!query.exec()) {
                    qDebug() << query.lastError().text();
                }
            }

            query.clear();
        }
    }

}
QString AppCore::getToken(QString username, QString password)
{
    jsonObj = new( QJsonObject );
    jsonObj->insert("name", username);
    jsonObj->insert("pass", password);
    return post ( "/access", *jsonObj );
}
QJsonObject AppCore::loadUserData () {  // get user data from db
    QJsonObject data;
    data["debug"] = 1;
    if ( !database.open() ) { qDebug() << database.lastError().text(); return data; }
    else {
        QSqlQuery query;
        query.exec("SELECT * FROM `user_data`");  // get user data from database
        if ( query.next() ) {
            data["username"] = query.value(0).toString();    // get username
            data["password"] = query.value(1).toString();    // get password
            data["status"] = query.value(2).toString();  // get status
            data["group"]  = query.value(3).toString();  // get group
            data["is_curator"] = query.value(4).toString();
            data["profile"]= query.value(5).toString();  // get ico
            data["debug"]  = "0";    // if all is ok, set zero value
        }
    }
    return  data;
}
QJsonObject AppCore::getConfig () { // get config values from db
    QJsonObject data;
    data["debug"] = "1";
    if ( !database.open() ) { qDebug() << database.lastError().text(); return data; }  // if error send 1 in debug
    else {
        QSqlQuery query;
        query.exec("SELECT * FROM `config`");   // reading config table
        if ( query.next() ) {
            data["first"] = query.value(0).toInt();
            data["theme"] = query.value(1).toInt();
            data["trafic"]= query.value(2).toInt();
            data["debug"] = "0";
        }
        query.clear();
    }
    return data;
}
QJsonArray AppCore::getMessages () {    // get messages from db
    QJsonArray data;
    QJsonObject sub;
    if ( !database.open() ) { qDebug() << database.lastError().text(); sub["debug"] = "1"; data.append(sub); }
    else {
        QSqlQuery query;
        query.exec("SELECT * FROM MESSAGES");
        while ( query.next() ) {
            sub["pick"] = query.value(2).toInt();
            sub["message"] = query.value(3).toString();
            sub["operator"] = query.value(4).toString();
            sub["date"] = query.value(5).toString();
            sub["debug"] = "0";
            data.append( sub );
        }
        query.clear();
    }
    return data;
}
QJsonArray AppCore::getTags () {    // get tags from db
    QJsonArray data;
    QJsonObject sub;
    if ( !database.open() ) { qDebug() << database.lastError().text(); sub["debug"] = "1"; data.append(sub); }
    else {
        QSqlQuery query;
        query.exec("SELECT * FROM tags");
        while ( query.next() ) {
            sub["tag"] = query.value(2).toString();
            sub["static"] = query.value(3).toString();
            sub["debug"] = "0";
            data.append( sub );
        }
        query.clear();
    }
    return data;
}
QJsonArray AppCore::getImages ( QString tag ) { // get images from db
    QJsonArray data;
    QJsonObject sub;
    if ( !database.open() ) { qDebug() << database.lastError().text(); sub["debug"] = "1"; data.append(sub); }
    else {
        QSqlQuery query;
        query.exec("SELECT * FROM images WHERE `tag` = \""+tag+"\"");
        while ( query.next() ) {
            sub["tag"]  = query.value(2).toString();
            sub["date"] = query.value(3).toString();
            sub["image"]= query.value(4).toString();
            sub["debug"] = "0";
            data.append( sub );
        }
        query.clear();
    }
    return data;
}
QJsonArray AppCore::getTasksDb() {
    QJsonArray data;
    QJsonObject sub;
    if ( !database.open() ) { qDebug() << database.lastError().text(); sub["debug"] = "1"; data.append(sub); }
    else {
        QSqlQuery query;
        query.exec("SELECT * FROM Tasks");
        while ( query.next() ) {
            sub["id"]   = query.value(0).toString();
            sub["group"]= query.value(1).toString();
            sub["tag"]  = query.value(2).toString();
            sub["task"] = query.value(3).toString();
            sub["attached"] = query.value(4).toString();
            sub["date_to"]  = query.value(5).toString();
            sub["operator"] = query.value(6).toString();
            sub["finished"] = query.value(7).toString();
            sub["debug"] = "0";
            data.append( sub );
        }
        query.clear();
    }
    return data;
}
void AppCore::uMessages () {  // update just messages
    if ( !database.open() ) { qDebug() << database.lastError().text(); }
    else {
        QSqlQuery query;
        QJsonObject uData = loadUserData();
        jsonObj = new( QJsonObject );
        jsonObj->insert("token", token);
        QJsonObject data = QJsonDocument::fromJson( post("/get-messages",*jsonObj).toUtf8() ).object();
        delete(jsonObj);
        query.exec("DELETE FROM messages");
        for ( int i = 0; i < data["messages"].toArray().size(); i++ ) {
            QJsonObject temp = data["messages"].toArray().at(i).toObject();
            query.exec("INSERT INTO messages (`groups`, `pick`, `message`, `operator`, `date`) VALUES (\""+temp["group"].toString()+"\", "+QString::number(temp["pick"].toInt())+", \""+temp["message"].toString()+"\", \""+temp["operator"].toString()+"\", \""+temp["date"].toString()+"\")");
        }
        query.clear();
    }
}
void AppCore::uTags () {  // update just tags
    if ( !database.open() ) { qDebug() << database.lastError().text(); }
    else {
        QSqlQuery query;
        QJsonObject uData = loadUserData();
        QJsonObject data = igetTags(0,"");
        query.exec("DELETE FROM tags");
        for ( int i = 0; i < data["tags"].toArray().size(); i++ ){
            QJsonObject temp = data["tags"].toArray().at(i).toObject();
            query.exec("INSERT INTO tags (`groups`, `tag`, `static`) VALUES (\""+uData["group"].toString()+"\", \""+temp["tag"].toString()+"\", "+QString::number(temp["static"].toInt())+")");
        }
        query.clear();
    }
}
void AppCore::uImages () {  // update just images
    if ( !database.open() ) { qDebug() << database.lastError().text(); }
    else {
        QSqlQuery query;
        QJsonObject user_data = loadUserData();
        QJsonObject tags = igetTags(0,"");


        query.exec("DELETE FROM images");
        query.exec("DELETE FROM tags");
        for ( int i = 0; i < tags["tags"].toArray().size(); i++ ) {
            QJsonObject item = tags["tags"].toArray().at(i).toObject();
            QJsonObject images = igetImages(item["tag"].toString(),"");

            for ( int i = 0; i < images["images"].toArray().count(); i++ ) {
                QJsonObject image = images["images"].toArray().at(i).toObject();
                query.exec("INSERT INTO images (`groups`,`tag`,`date`,`path`) VALUES (\""+user_data["group"].toString()+"\",\""+item["tag"].toString()+"\",\""+image["date"].toString()+"\",\""+image["image"].toString()+"\")"); // update images
            }

            query.exec("INSERT INTO tags (`groups`, `tag`, `static`) VALUES (\""+user_data["group"].toString()+"\",\""+item["tag"].toString()+"\","+QString::number(item["static"].toInt())+")");  // update tags
        }
        query.clear();
    }
}
void AppCore::uTasks() {
    if ( !database.open() ) { qDebug() << database.lastError().text(); }
    else {
        QSqlQuery query;
        QJsonObject uData = loadUserData();
        query.exec("DELETE FROM Tasks");
        jsonObj = new( QJsonObject );
        jsonObj->insert("self", "0");
        jsonObj->insert("token", token);
        QString info = post("/get-tasks", *jsonObj);
        delete(jsonObj);
        QJsonObject tasks = QJsonDocument::fromJson( info.toUtf8() ).object();
        for ( int i = 0; i < tasks["tasks"].toArray().count(); i++ ) {
            QJsonObject task = tasks["tasks"].toArray().at(i).toObject();
            //qDebug() << "INSERT INTO Tasks (`id`,`groups`,`tag`,`task`,`attached`,`date_to`,`operator`,`finished`) VALUES ("+QString::number(task["id"].toInt())+",\""+task["group"].toString()+"\", \""+task["tag"].toString()+"\",\""+task["task"].toString()+"\",\""+task["attached"].toString()+"\", \""+task["date_to"].toString()+"\", \""+task["operator"].toString()+"\", "+QString::number(task["finished"].toInt())+")";
            query.exec("INSERT INTO Tasks (`id`,`groups`,`tag`,`task`,`attached`,`date_to`,`operator`,`finished`) VALUES ("+QString::number(task["id"].toInt())+",\""+task["group"].toString()+"\", \""+task["tag"].toString()+"\",\""+task["task"].toString()+"\",\""+task["attached"].toString()+"\", \""+task["date_to"].toString()+"\", \""+task["operator"].toString()+"\", "+QString::number(task["finished"].toInt())+")");
        }
        query.clear();
    }
}
void AppCore::logout() {
    if ( !database.open() ) { qDebug() << database.lastError().text(); }
    else {
        QSqlQuery query;
        query.exec("DELETE FROM tags");     //clear tags
        query.exec("DELETE FROM images");   //clear images
        query.exec("DELETE FROM messages"); //clear messages
        query.exec("DELETE FROM Tasks");    //clear tasks
        query.exec("DELETE FROM user_data");//clear userdata
        query.exec("INSERT INTO user_data (`username`,`password`,`status`,`fgroup`,`is_curator`,`profile`) VALUES (\"\",\"\",\"\",\"\",1,\"\")");  // creating start values
    }
}
void AppCore::updateUser() {
    if ( !database.open() ) { qDebug() << database.lastError().text(); }
    else {
        QSqlQuery query;
        QJsonObject user_data = getMyProfile();
        QJsonObject user_base = loadUserData();
        query.exec("DELETE FROM user_data");//clear userdata
        query.exec("INSERT INTO user_data (`username`,`password`,`status`,`fgroup`,`is_curator`,`profile`) VALUES (\"\",\"\",\"\",\"\",1,\"\")");  // creating start values
        query.exec("UPDATE user_data SET `username` = \""+user_base["username"].toString()+"\", `password` = \""+user_base["password"].toString()+"\", `status` = \""+user_data["status"].toString()+"\", `fgroup` = \""+user_data["group"].toString()+"\",`is_curator` = \""+QString::number(user_data["is_curator"].toInt())+"\" , `profile` = \""+user_data["profile"].toString()+"\" "); // updating user data table
    }
}
QString AppCore::sendImage ( QString files, QString data ) {    // send image to server
    QString filepath = files;
    QString filename = QFileInfo(filepath).fileName();

    QFile *file = new QFile(filepath);
    QByteArray content;
    file->open(QIODevice::ReadOnly);
    content = file->readAll();

    QNetworkRequest newNetRequst(QUrl(api + data + "/" + token ));
    QNetworkAccessManager * newNetManager = new QNetworkAccessManager;
    QNetworkReply *newNetReply = newNetManager->post(newNetRequst, content);

    newNetManager->connect(newNetManager, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    loop.exec();

    return newNetReply->readAll();
}
QString AppCore::getCuratorTag(QString tag) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("tag", tag);
    jsonObj->insert("token", token);
    return post( "/get-curatorTag", *jsonObj );
}
int AppCore::checkConnection () {    // checking for internet connection
    qDebug() << "You are ok or you need some DEBUG?";
    QEventLoop *loop = new(QEventLoop);
    QNetworkAccessManager *netManager = new QNetworkAccessManager();
    QNetworkReply *netReply;
    QNetworkRequest netRequest;
    netRequest.setUrl( QUrl(api) );
    netReply = netManager->get( netRequest );
    netManager->connect( netManager, SIGNAL( finished( QNetworkReply* ) ), loop, SLOT( quit() ) );
    netManager->connect( netManager, SIGNAL( error( QNetworkReply::NetworkError ) ), loop, SLOT( quit() ) );
    loop->exec();
    qDebug() << "SOME...";
    if ( netReply->bytesAvailable() || netReply->readAll() != "" ) return 0;  // if get no data then return error
    else return 1;
}
QJsonObject AppCore::userImage ( QString url ) {    // get somebody profile ico
    QJsonObject obj;
    QString patientDbPath = "";
    QFile file(":/profile.jpg");
    if ( file.exists() ) {
        patientDbPath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
        if ( patientDbPath.isEmpty() ) {
            qDebug() << "Could not obtain writable location.";
            obj["debug"] = 1;
            return obj;
        }
        patientDbPath.append("/profile.jpg");
        QJsonObject user_data = loadUserData();
        if ( !QFile( patientDbPath ).exists() || user_data["profile"] != url ) {
            file.copy( patientDbPath );
            QFile::setPermissions(patientDbPath ,QFile::WriteOwner | QFile::ReadOwner) ;
            QFile current( patientDbPath );
            current.open(QIODevice::WriteOnly);
            checkable = 1;
            post( url, *new(QJsonObject) );
            current.write( userIco );
            current.close();
        }
        obj["path"] = "file:///" + patientDbPath;
        obj["debug"]= 0;

    }
    checkable = 0;
    return obj;
}
QString AppCore::sendTag ( QString tagName, QString curator, QString group ) { // add new tag
    jsonObj = new( QJsonObject );
    jsonObj->insert("tag", tagName);
    jsonObj->insert("group", group);
    if ( curator != "" )
        jsonObj->insert("curator", curator);
    else
        jsonObj->insert("curator", "0");
    jsonObj->insert("token", token);
    return post("/add-tag", *jsonObj );
}
QString AppCore::sendMessage (QString pick, QString message) {   // add new message
    jsonObj = new( QJsonObject );
    jsonObj->insert("pick", pick);
    jsonObj->insert("message", message);
    jsonObj->insert("token", token);
    return post("/add-message", *jsonObj);
}
QString AppCore::sendTask(QString group, QString tagName, QString task, QString date_to) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("tag", tagName);
    jsonObj->insert("task", task);
    jsonObj->insert("group", group);
    jsonObj->insert("date_to", date_to);
    jsonObj->insert("token", token);
    return post("/add-task", *jsonObj);
}
QString AppCore::deleteTag (QString group, QString tag ) {   // delete tag
    jsonObj = new( QJsonObject );
    jsonObj->insert("tag", tag);
    jsonObj->insert("group", group);
    jsonObj->insert("token", token);
    return post("/delete-tag", *jsonObj);
}
QString AppCore::deleteImage ( QString path) { // delete Image
    jsonObj = new( QJsonObject );
    jsonObj->insert("path", path);
    jsonObj->insert("token", token);
    return post("/delete-image", *jsonObj);
}
QString AppCore::deleteMessage ( QString pick, QString message, QString date) {    // delete Message
    jsonObj = new( QJsonObject );
    jsonObj->insert("pick", pick);
    jsonObj->insert("date", date);
    jsonObj->insert("message", message);
    jsonObj->insert("token", token);
    return post("/delete-message", *jsonObj);
}
QString AppCore::deleteTask(QString id) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("id", id);
    jsonObj->insert("token", token);
    return post("/delete-task", *jsonObj);
}
QString AppCore::deleteUser(QString username) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("username", username);
    jsonObj->insert("token", token);
    return post("/delete-user", *jsonObj);
}
QString AppCore::selectTask( QString id ) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("id", id);
    jsonObj->insert("token", token);
    return post( "/selectTask", *jsonObj);
}
QString AppCore::applyTask(QString id){
    jsonObj = new( QJsonObject );
    jsonObj->insert("id", id);
    jsonObj->insert("token", token);
    return post("/applyTask", *jsonObj);
}
QString AppCore::changeGroup(QString username, QString group) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("username", username);
    jsonObj->insert("group", group);
    jsonObj->insert("token", token);
    return post("/changeGroup", *jsonObj);
}
QString AppCore::newuser(QString username, QString password, QString group) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("username", username);
    jsonObj->insert("password", password);
    jsonObj->insert("group", group);
    return post("/add-user", *jsonObj);
}
QString AppCore::newUser(QString username, QString group, QString status ) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("name", username);
    jsonObj->insert("group", group);
    jsonObj->insert("status", status);
    jsonObj->insert("token", token);
    return post("/add-user", *jsonObj);
}
QString AppCore::selectStudent(QString id, QString user) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("id", id);
    jsonObj->insert("user", user);
    jsonObj->insert("token", token);
    return post( "/select-user", *jsonObj );
}
QJsonObject AppCore::getTasks( QString self, QString group ) {
    jsonObj = new( QJsonObject );
    if ( self != "" )
        jsonObj->insert("self", self);
    else
        jsonObj->insert("self", "0");
    if ( group != "" )
        jsonObj->insert("group", group);
    else
        jsonObj->insert("group", "0");
    jsonObj->insert("token", token);
    return QJsonDocument::fromJson( post("/get-tasks", *jsonObj).toUtf8() ).object();
}
QJsonObject AppCore::getMyProfile() {
    jsonObj = new( QJsonObject );
    jsonObj->insert("token", token);
    return QJsonDocument::fromJson( post("/get-profile", *jsonObj).toUtf8() ).object();
}
QJsonObject AppCore::getCurator() {
    jsonObj = new( QJsonObject );
    jsonObj->insert("token", token);
    return QJsonDocument::fromJson( post("/get-curator", *jsonObj).toUtf8() ).object();
}
QJsonObject AppCore::igetGroups() {
    return QJsonDocument::fromJson( post("/get-groups", *new(QJsonObject)).toUtf8() ).object();
}
QJsonObject AppCore::igetTags( int all, QString group ) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("all", QString::number(all) );
    if ( group != "" )
        jsonObj->insert("group", group);
    else
        jsonObj->insert("group", "0");
    jsonObj->insert("token", token);
    return QJsonDocument::fromJson( post("/get-tags", *jsonObj).toUtf8() ).object();
}
QJsonObject AppCore::igetImages(QString tag, QString date) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("tag", tag);
    if ( date != "" ) {
        jsonObj->insert("date", date);
        jsonObj->insert("tag", "0");
    } else {
        jsonObj->insert("date", "0");
        jsonObj->insert("tag", tag);
    }
    jsonObj->insert("token", token);
    return QJsonDocument::fromJson( post("/get-images", *jsonObj ).toUtf8() ).object();
}
QJsonObject AppCore::getProfile( QString username ) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("token", token);
    if ( username != "" )
        jsonObj->insert("username", username);
    else
        jsonObj->insert("username", "0");
    return QJsonDocument::fromJson( post("/get-profile", *jsonObj ).toUtf8() ).object();
}
QJsonObject AppCore::getUsers( int s, QString group ) {
    QJsonObject object;
    jsonObj = new( QJsonObject);
    if ( group != "" )
        jsonObj->insert("group", group);
    else
        jsonObj->insert("group", "0");
    if ( checkConnection() == 0 ) {
        if ( s == 1 )
            jsonObj->insert("type", "s");
        else if ( s == 2 )
            jsonObj->insert("type", "c");
        else if ( s == 3 )
            jsonObj->insert("type", "a");
        object = object = QJsonDocument::fromJson( post("/get-users", *jsonObj ).toUtf8() ).object();
        object["debug"] = 0;
    }
    return object;
}
QJsonObject AppCore::getUser(QString username) {
    jsonObj = new( QJsonObject );
    jsonObj->insert("currentUser", username);
    jsonObj->insert("token", token);
    return QJsonDocument::fromJson( post("/get-currentUser", *jsonObj).toUtf8() ).object();
}
QJsonObject AppCore::profileImage(QString url) {
    QJsonObject obj;
    QString patientDbPath = "";
    QFile file(":images/profile.jpg");
    if ( file.exists() ) {
        patientDbPath = QDir().absolutePath();
        if ( patientDbPath.isEmpty() ) {
            qDebug() << "Could not obtain writable location.";
            obj["debug"] = 1;
            return obj;
        }
        patientDbPath.append("/data/profile.jpg");
        QJsonObject user_data = loadUserData();
        if ( !QFile( patientDbPath ).exists() || user_data["profile"] != url ) {
            file.copy( patientDbPath );
            QFile::setPermissions(patientDbPath ,QFile::WriteOwner | QFile::ReadOwner) ;
            QFile current( patientDbPath );
            current.open(QIODevice::WriteOnly);
            checkable = 1;
            post( url, *new(QJsonObject) );
            current.write( userIco );
            current.close();
        }
        obj["path"] = patientDbPath;
        obj["debug"]= 0;

    }
    checkable = 0;
    return obj;
}
QString AppCore::getHashed(QString string) {
    return string.toUtf8();
}
void AppCore::close() {
    token = "";
    database.close();
}
