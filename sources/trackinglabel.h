#ifndef TRACKINGLABEL_H
#define TRACKINGLABEL_H

#include <QLabel>
#include <QMouseEvent>
#include <QPoint>
#include <QCursor>

class trackingLabel : public QObject
{
    Q_OBJECT
public:
    explicit trackingLabel( QObject * parent = nullptr );
    virtual ~trackingLabel() = default;
    Q_INVOKABLE QPointF cursorPos() { return QCursor::pos();  }
};

#endif // TRACKINGLABEL_H
