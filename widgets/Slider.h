#ifndef SLIDER_H_INCLUDED
#define SLIDER_H_INCLUDED

#include <vector>
#include <string>

#include <QWidget>

#include "tinyxml2.h"

class Proxy;
class UIProxy;

#include "Widget.h"
#include "Event.h"

class Slider : public Widget, public EventOnChangeInt
{
protected:
    int minimum;
    int maximum;

    virtual Qt::Orientation getOrientation() = 0;

public:
    Slider();
    virtual ~Slider();

    bool parse(tinyxml2::XMLElement *e, std::vector<std::string>& errors);
    QWidget * createQtWidget(Proxy *proxy, UIProxy *uiproxy, QWidget *parent);

    friend class UIFunctions;
};

#endif // SLIDER_H_INCLUDED
