#include "UIFunctions.h"
#include "debug.h"
#include "UIProxy.h"

#include <QThread>

#include <iostream>

#include "stubs.h"

// UIFunctions is a singleton

UIFunctions *UIFunctions::instance = NULL;

UIFunctions::UIFunctions(QObject *parent)
    : QObject(parent)
{
    // connect signals/slots from UIProxy to UIFunctions and vice-versa

    UIProxy *uiproxy = UIProxy::getInstance();
    connect(this, SIGNAL(create(Proxy*)), uiproxy, SLOT(onCreate(Proxy*)), Qt::BlockingQueuedConnection);
    connect(uiproxy, SIGNAL(buttonClick(Widget*)), this, SLOT(onButtonClick(Widget*)));
    connect(uiproxy, SIGNAL(valueChange(Widget*,int)), this, SLOT(onValueChange(Widget*,int)));
    connect(uiproxy, SIGNAL(valueChange(Widget*,QString)), this, SLOT(onValueChange(Widget*,QString)));
    connect(uiproxy, SIGNAL(editingFinished(Edit*,QString)), this, SLOT(onEditingFinished(Edit*,QString)));
    connect(uiproxy, SIGNAL(windowClose(Window*)), this, SLOT(onWindowClose(Window*)));
    connect(this, SIGNAL(destroy(Proxy*)), uiproxy, SLOT(onDestroy(Proxy*)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(showWindow(Window*)), uiproxy, SLOT(onShowWindow(Window*)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(hideWindow(Window*)), uiproxy, SLOT(onHideWindow(Window*)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setImage(Image*,const char*,int,int)), uiproxy, SLOT(onSetImage(Image*,const char*,int,int)), Qt::BlockingQueuedConnection);
    connect(uiproxy, SIGNAL(loadImageFromFile(Image*,const char *,int,int)), this, SLOT(onLoadImageFromFile(Image*,const char *,int,int)));
    connect(this, SIGNAL(sceneChange(Window*,int,int)), uiproxy, SLOT(onSceneChange(Window*,int,int)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setEnabled(Widget*,bool)), uiproxy, SLOT(onSetEnabled(Widget*,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setEditValue(Edit*,std::string,bool)), uiproxy, SLOT(onSetEditValue(Edit*,std::string,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setLabelText(Label*,std::string,bool)), uiproxy, SLOT(onSetLabelText(Label*,std::string,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setSliderValue(Slider*,int,bool)), uiproxy, SLOT(onSetSliderValue(Slider*,int,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setCheckboxValue(Checkbox*,int,bool)), uiproxy, SLOT(onSetCheckboxValue(Checkbox*,int,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(setRadiobuttonValue(Radiobutton*,int,bool)), uiproxy, SLOT(onSetRadiobuttonValue(Radiobutton*,int,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(insertComboboxItem(Combobox*,int,std::string,bool)), uiproxy, SLOT(onInsertComboboxItem(Combobox*,int,std::string,bool)), Qt::BlockingQueuedConnection);
    connect(this, SIGNAL(removeComboboxItem(Combobox*,int,bool)), uiproxy, SLOT(onRemoveComboboxItem(Combobox*,int,bool)), Qt::BlockingQueuedConnection);
}

UIFunctions::~UIFunctions()
{
    UIFunctions::instance = NULL;
}

UIFunctions * UIFunctions::getInstance(QObject *parent)
{
    if(!UIFunctions::instance)
    {
        UIFunctions::instance = new UIFunctions(parent);

        DBG << "UIFunctions constructed in thread " << QThread::currentThreadId() << std::endl;

        simThread();
    }
    return UIFunctions::instance;
}

void UIFunctions::destroyInstance()
{
    if(UIFunctions::instance)
        delete UIFunctions::instance;
}

void UIFunctions::onButtonClick(Widget *widget)
{
    if(!widget) return;
    if(!widget->proxy) return;

    EventOnClick *e = dynamic_cast<EventOnClick*>(widget);

    if(!e) return;
    if(e->onclick == "" || widget->proxy->scriptID == -1) return;

    onclickCallback_in in_args;
    in_args.handle = widget->proxy->handle;
    in_args.id = widget->id;
    onclickCallback_out out_args;
    onclickCallback(widget->proxy->scriptID, e->onclick.c_str(), &in_args, &out_args);
}

void UIFunctions::onValueChange(Widget *widget, int value)
{
    if(!widget) return;
    if(!widget->proxy) return;

    EventOnChangeInt *e = dynamic_cast<EventOnChangeInt*>(widget);

    if(!e) return;
    if(e->onchange == "" || widget->proxy->scriptID == -1) return;

    onchangeIntCallback_in in_args;
    in_args.handle = widget->proxy->handle;
    in_args.id = widget->id;
    in_args.value = value;
    onchangeIntCallback_out out_args;
    onchangeIntCallback(widget->proxy->scriptID, e->onchange.c_str(), &in_args, &out_args);
}

void UIFunctions::onValueChange(Widget *widget, QString value)
{
    if(!widget) return;
    if(!widget->proxy) return;

    EventOnChangeString *e = dynamic_cast<EventOnChangeString*>(widget);

    if(!e) return;
    if(e->onchange == "" || widget->proxy->scriptID == -1) return;

    onchangeStringCallback_in in_args;
    in_args.handle = widget->proxy->handle;
    in_args.id = widget->id;
    in_args.value = value.toStdString();
    onchangeStringCallback_out out_args;
    onchangeStringCallback(widget->proxy->scriptID, e->onchange.c_str(), &in_args, &out_args);
}

void UIFunctions::onEditingFinished(Edit *edit, QString value)
{
    if(!edit) return;
    if(!edit->proxy) return;

    EventOnEditingFinished *e = dynamic_cast<EventOnEditingFinished*>(edit);

    if(!e) return;
    if(e->oneditingfinished == "" || edit->proxy->scriptID == -1) return;

    oneditingfinishedCallback_in in_args;
    in_args.handle = edit->proxy->handle;
    in_args.id = edit->id;
    in_args.value = value.toStdString();
    oneditingfinishedCallback_out out_args;
    oneditingfinishedCallback(edit->proxy->scriptID, e->oneditingfinished.c_str(), &in_args, &out_args);
}

void UIFunctions::onWindowClose(Window *window)
{
    if(!window) return;
    if(!window->proxy) return;

    oncloseCallback_in in_args;
    in_args.handle = window->proxy->getHandle();
    oncloseCallback_out out_args;
    oncloseCallback(window->proxy->getScriptID(), window->onclose.c_str(), &in_args, &out_args);
}

void UIFunctions::onLoadImageFromFile(Image *image, const char *filename, int w, int h)
{
    QImage::Format format = QImage::Format_RGB888;
    int bpp = 3; // bytes per pixel
    int resolution[2];
    simUChar *data = simLoadImage(resolution, 0, filename, NULL);
    simTransformImage(data, resolution, 4, NULL, NULL, NULL);

    if(w > 0 && h > 0)
    {
        int size[2] = {w, h};
        simUChar *scaled = simGetScaledImage(data, resolution, size, 0, NULL);
        simReleaseBufferE((simChar *)data);
        setImage(image, (simChar *)scaled, w, h);
    }
    else
    {
        setImage(image, (simChar *)data, resolution[0], resolution[1]);
    }
}

