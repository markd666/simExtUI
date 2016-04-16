#ifndef LAYOUTWIDGET_H_INCLUDED
#define LAYOUTWIDGET_H_INCLUDED

#include <vector>
#include <string>

#include <QWidget>

#include "tinyxml2.h"

#include "Widget.h"

class Proxy;
class UIProxy;
class Widget;

enum Layout
{
    VBOX = 1,
    HBOX,
    GRID,
    FORM
};

class Stretch : public Widget
{
protected:
    int factor;

public:
    Stretch();

    const char * name();
    bool parse(tinyxml2::XMLElement *e, std::vector<std::string>& errors);    
    QWidget * createQtWidget(Proxy *proxy, UIProxy *uiproxy, QWidget *parent);

    friend class LayoutWidget;
};

class LayoutWidget
{
protected:
    Layout layout;
    std::vector< std::vector<Widget*> > children;

public:
    virtual ~LayoutWidget();

    bool parse(tinyxml2::XMLElement *e, std::vector<std::string>& errors);    
    void createQtWidget(Proxy *proxy, UIProxy *uiproxy, QWidget *parent);
};

#endif // LAYOUTWIDGET_H_INCLUDED
